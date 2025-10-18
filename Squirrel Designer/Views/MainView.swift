//
//  MainView.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/26/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI
import SwiftData
import Yams

enum RenamingError: Error {
    case emptyName
    case reservedName(String)
    case duplicatedName(String)
}

struct MainView: View {
    @Environment(ViewModel.self) var viewModel
    @State private var renamingIndex: Int?
    @FocusState private var focusedIndex: Int?
    @State private var newName: String = ""
    @Environment(\.colorScheme) var appearance

    var body: some View {
        NavigationSplitView {
            let list = List(selection: viewModel.binding(\.selection)) {
                Text("STYLE")
                    .tag(Selection.style)
                colorSchemesSection
            }
            if #available(macOS 26.0, *) {
                list
                .safeAreaBar(edge: .bottom) {
                    pinnedBottomMenu
                }
            } else {
                list
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    pinnedBottomButtons
                }
            }
        } detail: {
            detailsView
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button("UNDO", systemImage: "arrow.uturn.backward") {
                    viewModel.undoManager.undo()
                }
                .disabled(!viewModel.undoManager.canUndo)
                Button("REDO", systemImage: "arrow.uturn.forward") {
                    viewModel.undoManager.redo()
                }
                .disabled(!viewModel.undoManager.canRedo)
            }
        }
        .errorAlert()
        .onAppear {
            initializePreviewPosition()
            autoRefreshPreview()
        }
        .onChange(of: appearance) {
            if viewModel.previewing {
                viewModel.panel.update(inputTemplate: viewModel.inputTemplate)
            }
        }
    }

    var colorSchemesSection: some View {
        Section {
            ForEach(viewModel.squirrelSetting.colorSchemes.indices.map { Selection.colorScheme($0) }, id: \.self) { sel in
                switch sel {
                case .colorScheme(let index):
                    if let renamingIndex, renamingIndex == index {
                        TextField("NEWNAME", text: $newName)
                            .focused($focusedIndex, equals: index)
                            .onAppear {
                                focusedIndex = index
                                newName = viewModel.squirrelSetting.colorSchemes[index].codeName
                            }
                            .onSubmit {
                                submitNameChange(index: index)
                            }
                            .onChange(of: focusedIndex) {
                                if focusedIndex != index {
                                    submitNameChange(index: index)
                                }
                            }
                            .submitLabel(.done)
                    } else {
                        if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
                            Text(viewModel.squirrelSetting.colorSchemes[index].codeName)
                                .contextMenu {
                                    Button("RENAME", systemImage: "pencil") {
                                        performRename(index: index)
                                    }
                                    Button("DUPLICATE", systemImage: "document.on.document") {
                                        performDuplication(index: index)
                                    }
                                    Button("DELETE", systemImage: "trash", role: .destructive) {
                                        if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
                                            viewModel.squirrelSetting.colorSchemes.remove(at: index)
                                            viewModel.save()
                                            if case let .colorScheme(idx) = viewModel.selection, index <= idx {
                                                if idx <= 0 {
                                                    viewModel.selection = .style
                                                } else {
                                                    viewModel.selection = .colorScheme(idx - 1)
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .onMove { from, to in
                viewModel.squirrelSetting.colorSchemes.move(fromOffsets: from, toOffset: to)
                viewModel.save()
            }
        } header: {
            AddableTitle(title: "COLOR_SCHEMES", show: true) {
                Button("ADD_ITEM", systemImage: "plus.circle") {
                    addNewScheme()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)

            }
        }
    }

    var pinnedBottomButtons: some View {
        List(selection: viewModel.binding(\.selection)) {
            Text("ALL_CODE")
                .tag(Selection.allSettings)
            Text("TEMPLATE")
                .tag(Selection.template)
        }
        .frame(maxHeight: 75)
        .listStyle(.sidebar)
        .padding(.top, 10)
        .background(.ultraThinMaterial)
    }

    @available(macOS 26.0, *)
    var pinnedBottomMenu: some View {
        HStack {
            Menu("SETTINGS", systemImage: "ellipsis") {
                Button("ALL_CODE", systemImage: "doc.append.rtl") {
                    viewModel.selection = .allSettings
                }
                .labelStyle(.titleAndIcon)
                Button("TEMPLATE", systemImage: "filemenu.and.selection") {viewModel.selection = .template
                }
                .labelStyle(.titleAndIcon)
            }
            .padding(5)
            .menuIndicator(.hidden)
            .menuStyle(.button)
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
            .buttonStyle(.borderless)
            .glassEffect(.clear.tint(.accentColor.opacity(0.12)))
            Spacer()
        }
        .padding(7)
    }

    var detailsView: some View {
        Group {
            if viewModel.showingCode {
                CodeView()
            } else {
                switch viewModel.selection {
                case .style:
                    StyleView()
                case .template:
                    TemplateView()
                case .colorScheme(let index):
                    if (0..<viewModel.squirrelSetting.colorSchemes.count).contains(index) {
                        ColorSchemeView(index: index)
                    }
                case .allSettings:
                    CodeView()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Toggle(isOn: viewModel.binding(\.previewing)) {
                    Label("PREVIEW", systemImage: "eye")
                }
                .labelStyle(.titleOnly)
                .onChange(of: viewModel.previewing, initial: false) {
                    if viewModel.previewing {
                        if var position = viewModel.previewPosition {
                            if let screen = NSScreen.main?.frame, !screen.contains(position) {
                                initializePreviewPosition()
                                position = viewModel.previewPosition!
                                position.y -= viewModel.panel.frame.height
                            }
                            viewModel.panel.setFrameOrigin(position)
                        }
                        viewModel.panel.update(inputTemplate: viewModel.inputTemplate)
                    } else {
                        viewModel.previewPosition = viewModel.panel.frame.origin
                        viewModel.panel.hide()
                    }
                }
                if viewModel.selection != .allSettings {
                    Picker("VIEW_MODE", selection: viewModel.binding(\.showingCode)) {
                        ForEach([true, false], id: \.self) { isOn in
                            Text(isOn ? "CODE" : "TOOL")
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    func addNewScheme() {
        var newScheme = ColorScheme()
        newScheme.codeName = validName(String(localized: "NEW_SCHEME_NAME"))
        viewModel.squirrelSetting.colorSchemes.insert(newScheme, at: 0)
        viewModel.save()
        performRename(index: 0)
        viewModel.selection = .colorScheme(0)
    }

    func performDuplication(index: Int) {
        if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
            var copiedScheme = viewModel.squirrelSetting.colorSchemes[index]
            copiedScheme.codeName = validName(copiedScheme.codeName)
            viewModel.squirrelSetting.colorSchemes.insert(copiedScheme, at: index + 1)
            viewModel.save()
            performRename(index: index + 1)
            viewModel.selection = .colorScheme(index + 1)
        }
    }

    func performRename(index: Int) {
        if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
            renamingIndex = index
            Task {
                focusedIndex = index
            }
        }
    }

    private func validName(_ name: String) -> String {
        let existingNames = viewModel.squirrelSetting.colorSchemes.map(\.codeName)
        var (baseName, i) = reverseNumberedName(name)
        while existingNames.contains(numberedName(baseName, number: i)) {
            i += 1
        }
        return numberedName(baseName, number: i)

        func numberedName(_ baseName: String, number: Int) -> String {
            if number <= 1 {
                return baseName
            } else {
                return "\(baseName) \(number)"
            }
        }

        func reverseNumberedName(_ name: String) -> (String, Int) {
            let namePattern = /^(.*) (\d+)$/
            if let match = try? namePattern.firstMatch(in: name) {
                return (String(match.output.1), Int(match.output.2)!)
            } else {
                return (name, 1)
            }
        }
    }

    func submitNameChange(index: Int) {
        if newName.isEmpty {
            viewModel.error = .renaming(.emptyName)
        } else if newName == "native" {
            viewModel.error = .renaming(.reservedName(newName))
        } else if newName != viewModel.squirrelSetting.colorSchemes[index].codeName && validName(newName) != newName {
            viewModel.error = .renaming(.duplicatedName(newName))
        } else {
            viewModel.squirrelSetting.colorSchemes[index].codeName = newName
            viewModel.save()
        }
        newName = ""
        self.renamingIndex = nil
    }

    private func autoRefreshPreview() {
        withObservationTracking {
            _ = viewModel.inputTemplate
            _ = viewModel.squirrelSetting
            _ = viewModel.selection
        } onChange: {
            Task { @MainActor in
                if viewModel.previewing {
                    viewModel.panel.update(inputTemplate: viewModel.inputTemplate)
                }
                autoRefreshPreview()
            }
        }
    }

    private func initializePreviewPosition() {
        if let frame = NSApp.windows.first?.frame {
            viewModel.previewPosition = CGPoint(x: frame.minX + 10, y: frame.minY - 10)
        }
    }
}

struct ErrorAlert: ViewModifier {
    @Environment(ViewModel.self) private var viewModel

    func body(content: Content) -> some View {
        content
            .alert("ERROR", isPresented: viewModel.binding(\.hasError)) {
                Button("OK", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                if let _error = viewModel.error {
                    if case let .decoding(error) = _error {
                        switch error {
                        case let .valueNotFound(type, context):
                            Text("\(context.debugDescription)\nVALUE_OF_TYPE\(String(describing: type))NOT_FOUND_IN\(context.codingPath.map({$0.stringValue}).joined(separator: "/"))")
                        case let .dataCorrupted(context):
                            Text("\(context.debugDescription)\nIN\(context.codingPath.map({$0.stringValue}).joined(separator: "/"))")
                        case let .typeMismatch(type, context):
                            Text("\(context.debugDescription)\n\(String(describing: type))FOUND_IN\(context.codingPath.map({$0.stringValue}).joined(separator: "/"))")
                        case let .keyNotFound(key, context):
                            Text("\(context.debugDescription)\n\(key.stringValue)KEY_NOT_FOUND_IN\(context.codingPath.map({$0.stringValue}).joined(separator: "/"))")
                        @unknown default:
                            Text(_error.localizedDescription)
                        }
                    } else if case let .renaming(error) = _error {
                        switch error {
                        case .emptyName:
                            Text("EMPTY_NAME_ERROR")
                        case .duplicatedName(let newName):
                            Text("NAME_DUP_ERROR_NAME\(newName)")
                        case .reservedName(let newName):
                            Text("RESERVED_NAME_ERROR\(newName)")
                        }
                    } else {
                        Text(_error.localizedDescription)
                    }
                } else {
                    EmptyView()
                }
            }
    }
}

extension View {
    func errorAlert() -> some View {
        self.modifier(ErrorAlert())
    }
}

#Preview("Squirrel Designer", traits: .modifier(SampleData())) {
    MainView()
}
