//
//  StyleView.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/26/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI

struct StyleView: View {
    @Environment(ViewModel.self) var viewModel
    private var _style: Binding<Style> {
        Binding(get: {
            viewModel.squirrelSetting.style
        }, set: { newValue in
            viewModel.squirrelSetting.style = newValue
            viewModel.saveTask?.cancel()
            viewModel.saveTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                viewModel.save()
            }
        })
    }
    private var style: Style {
        _style.wrappedValue
    }

    var body: some View {
        Form {
            formatSection
            schemeSection
            fontsSection
            switchesSection
            nemericSection
        }
        .formStyle(.grouped)
        .navigationTitle("STYLE")
    }

    var formatSection: some View {
        Section {
            StaticRow {
                Picker("STATUS_MSG_TYPE", selection: _style.statusMessageType) {
                    ForEach(StatusMessageType.allCases, id: \.self) { type in
                        switch type {
                        case .long:
                            Text("STATUS_MSG_LONG")
                        case .mix:
                            Text("STATUS_MSG_MIX")
                        case .short:
                            Text("STATUS_MSG_SHORT")
                        }
                    }
                }
            }
            StaticRow {
                TextField("CAND_FORMAT", text: _style.candidateFormat)
                    .textFieldStyle(.roundedBorder)
            }
        } footer: {
            Text(String(localized: "CAND_FORMAT_TIP") + String("[label], [candidate], [comment]"))
        }
    }

    var schemeSection: some View {
        Section {
            StaticRow {
                Picker("SCHEME", selection: _style.lightScheme) {
                    ForEach(["native"] + viewModel.squirrelSetting.colorSchemes.map { $0.codeName }, id: \.self) { codeName in
                        Text(codeName)
                    }
                }
            }
            DeletableRow(optional: _style.darkScheme) {
                Picker("DARK_SCHEME", selection: _style.darkScheme.unwrap(default: style.lightScheme)) {
                    ForEach(["native"] + viewModel.squirrelSetting.colorSchemes.map { $0.codeName }, id: \.self) { codeName in
                        Text(codeName)
                    }
                }
            }
        } header: {
            AddableTitle(title: "SCHEMES", show: style.darkScheme == nil ) {
                Menu {
                    if style.darkScheme == nil {
                        Button("ADD_DARK_SCHEME") {
                            _style.wrappedValue.darkScheme = style.lightScheme
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }

    var switchesSection: some View {
        Section("SWITCHES") {
            LazyVGrid(columns: viewModel.gridColumns, spacing: 20) {
                Toggle("IS_LINEAR", isOn: _style.linear)
                Toggle("IS_VERTICAL", isOn: _style.vertical)
                Toggle("IS_INLINE_PREEDIT", isOn: _style.inlinePreedit)
                Toggle("IS_INLINE_CAND", isOn: _style.inlineCandidate)
                Toggle("IS_TRANSLUCENT", isOn: _style.translucency)
                Toggle("IS_MUTUAL_EXCLUSIVE", isOn: _style.mutualExclusive)
                Toggle("IS_MEMORIZING_SIZE", isOn: _style.memorizeSize)
                Toggle("IS_SHOWING_PAGING", isOn: _style.showPaging)
            }
        }
    }

    var nemericSection: some View {
        Section("NUMERICS") {
            LazyVGrid(columns: viewModel.gridColumns, spacing: 20) {
                SliderCell("ALPHA", value: _style.alpha, in: 0...1)
                NemericalCell("CORNER_RADIUS", value: _style.cornerRadius) { max(0, $0) }
                NemericalCell("HILIT_CORNER_RADIUS", value: _style.hilitedCornerRadius) { max(0, $0) }
                NemericalCell("SUR_EXTRA_EXPAN", value: _style.surroundingExtraExpansion)
                NemericalCell("BORDER_HEIGHT", value: _style.borderHeight)
                NemericalCell("BORDER_WIDTH", value: _style.borderWidth)
                NemericalCell("CAND_LINESPACE", value: _style.linespace)
                NemericalCell("PREEDIT_LINESPACE", value: _style.preeditLinespace)
                NemericalCell("FONT_BASE_OFFSET", value: _style.baseOffset)
                NemericalCell("SHADOW_SIZE", value: _style.shadowSize) { max(0, $0) }
            }

        }
    }

    var fontsSection: some View {
        Section {
            FontsSelector("FONT", allowEmpty: false, fonts: _style.fonts)
            if style.labelFont != nil {
                FontsSelector("LABEL_FONT", allowEmpty: true, fonts: _style.labelFonts)
            }
            if style.commentFont != nil {
                FontsSelector("COMMENT_FONT", allowEmpty: true, fonts: _style.commentFonts)
            }
        } header: {
            AddableTitle(title: "FONTS", show: [style.labelFont, style.commentFont].reduce(false, { $0 || $1 == nil })) {
                Menu {
                    if style.labelFont == nil {
                        Button("ADD_LABEL_FONTS") {
                            _style.wrappedValue.labelFont = style.font
                        }
                    }
                    if style.commentFont == nil {
                        Button("ADD_COMMENT_FONTS") {
                            _style.wrappedValue.commentFont = style.font
                        }
                    }
                    if style.labelFont == nil || style.commentFont == nil {
                        Divider()
                    }
                    Button("ADD_FONT") {
                        _style.wrappedValue.fonts.append(style.font)
                    }
                    if style.labelFont != nil {
                        Button("ADD_LABEL_FONT") {
                            _style.wrappedValue.labelFonts.append(style.labelFont!)
                        }
                    }
                    if style.commentFont != nil {
                        Button("ADD_COMMENT_FONT") {
                            _style.wrappedValue.commentFonts.append(style.commentFont!)
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }
}

struct FontsSelector: View {
    let titleKey: LocalizedStringKey
    let allowEmpty: Bool
    @Binding var fonts: [NSFont]
    let defaultFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)

    init(_ titleKey: LocalizedStringKey, allowEmpty: Bool, fonts: Binding<[NSFont]>) {
        self.titleKey = titleKey
        self.allowEmpty = allowEmpty
        self._fonts = fonts
    }

    var body: some View {
        if !fonts.isEmpty {
            HStack {
                Text(titleKey)
                Divider()
                let size: Binding<Double> = Binding(get: {fonts[0].pointSize}, set: {fonts[0] = fonts[0].withSize($0)})
                NemericalCell("FONT_SIZE", value: size) { max(5, $0) }
                    .frame(maxWidth: 120)
                    .lineLimit(1)
                List {
                    ForEach(0..<fonts.count, id: \.self) { index in
                        HStack {
                            FontSelector(font: $fonts[index])
                            if (index == 0 && (allowEmpty || fonts.count > 1)) || index > 0 {
                                Button {
                                    if index >= 0 && index < fonts.count {
                                        fonts.remove(at: index)
                                    }
                                } label: {
                                    Label("DELETE_ROW", systemImage: "minus.circle")
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.borderless)
                            } else {
                                Label("DELETE_ROW", systemImage: "minus.circle")
                                    .labelStyle(.iconOnly)
                                    .hidden()
                            }
                        }
                    }
                    .onMove { from, to in
                        fonts.move(fromOffsets: from, toOffset: to)
                    }
                }
            }
        }
    }
}

struct FontSelector: View {
    @Binding var font: NSFont
    @State private var fontFamily: String
    @State private var attributeName: String
    private let allFonts = [NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName!] + NSFontManager.shared.availableFontFamilies

    init(font: Binding<NSFont>) {
        let (family, member) = getFontFamilyAndMember(font: font.wrappedValue)
        let fontFamily = family ?? allFonts.first ?? ""
        let allMembers = populateFontMembers(for: fontFamily)
        let attributeName = member ?? allMembers.first ?? ""
        self._font = font
        self.fontFamily = fontFamily
        self.attributeName = attributeName
    }

    var body: some View {
        HStack {
            Picker("FONT_NAME", selection: $fontFamily) {
                ForEach(allFonts, id: \.self) { fontFamilyName in
                    Text(fontFamilyName)
                }
            }
            Picker("FONT_WEIGHT", selection: $attributeName) {
                ForEach(populateFontMembers(for: fontFamily), id: \.self) { fontAttribute in
                    Text(fontAttribute)
                }
            }
        }
        .onChange(of: fontFamily) {
            font ?= readFont(family: fontFamily, style: attributeName, size: font.pointSize)
        }
        .onChange(of: attributeName) {
            font ?= readFont(family: fontFamily, style: attributeName, size: font.pointSize)
        }
        .onChange(of: font) {
            let (family, member) = getFontFamilyAndMember(font: font)
            let fontFamily = family ?? allFonts.first ?? ""
            let allMembers = populateFontMembers(for: fontFamily)
            let attributeName = member ?? allMembers.first ?? ""
            self.fontFamily = fontFamily
            self.attributeName = attributeName
        }
    }
}

#Preview("StyleView", traits: .modifier(SampleData())) {
    StyleView()
}
