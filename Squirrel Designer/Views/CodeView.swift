//
//  CodeView.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/27/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI
import Yams

struct CodeView: View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    @State private var code: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        switch viewModel.selection {
        case .style:
            editor
                .task(id: viewModel.squirrelSetting.style) {
                    encode()
                }
                .navigationTitle("STYLE")
        case .colorScheme(let index):
            let view = editor
                .task(id: viewModel.squirrelSetting.colorSchemes[index]) {
                    encode()
                }
                .navigationTitle("COLOR_SCHEME:\(viewModel.squirrelSetting.colorSchemes[index].codeName)")
            if let name = viewModel.squirrelSetting.colorSchemes[index].name {
                view
                    .navigationSubtitle(name)
            } else {
                view
            }
        case .template:
            editor
                .task(id: viewModel.inputTemplate) {
                    encode()
                }
                .navigationTitle("TEMPLATE")
        case .allSettings:
            editor
                .task(id: viewModel.squirrelSetting) {
                    encode()
                }
                .navigationTitle("ALL_CODE")
        }
    }

    var editor: some View {
        Group {
            if isEditing {
                TextEditor(text: $code)

            } else {
                TextEditor(text: .constant(code))
            }
        }
        .lineSpacing(5)
        .font(.system(.body, design: .monospaced))
        .padding()
        .scrollContentBackground(.hidden)
        .background(isEditing ? .thinMaterial : .bar, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                if isEditing {
                    Button("RESTORE", systemImage: "arrow.trianglehead.counterclockwise") {
                        encode()
                        isEditing = false
                    }
                }
                Toggle(isOn: $isEditing) {
                    if isEditing {
                        Label("DONE", systemImage: "checkmark")
                    } else {
                        Label("EDIT", systemImage: "square.and.pencil")
                    }
                }
                .onChange(of: isEditing) {
                    if !isEditing {
                        do {
                            try decode()
                            viewModel.save()
                        } catch let error as YamlError {
                            isEditing = true
                            viewModel.error = .yamlError(error)
                        } catch let error as DecodingError {
                            isEditing = true
                            viewModel.error = .decoding(error)
                        } catch {
                            isEditing = true
                            viewModel.error = .other(error)
                        }
                    }
                }
            }
        }
    }

    func encode() {
        let encoder = YAMLEncoder()
        encoder.options.allowUnicode = true
        do {
            switch viewModel.selection {
            case .style:
                code = try encoder.encode(viewModel.squirrelSetting.style)
            case .template:
                code = try encoder.encode(viewModel.inputTemplate)
            case .colorScheme(let schemeCode):
                code = try encoder.encode(viewModel.squirrelSetting.colorSchemes[schemeCode])
            case .allSettings:
                code = try encoder.encode(viewModel.squirrelSetting)
            }
        } catch let error as YamlError {
            viewModel.error = .yamlError(error)
        } catch let error as EncodingError {
            viewModel.error = .encoding(error)
        } catch {
            viewModel.error = .other(error)
        }
    }

    func decode() throws {
        let decoder = YAMLDecoder()
        switch viewModel.selection {
        case .style:
            viewModel.squirrelSetting.style = try decoder.decode(Style.self, from: code)
        case .template:
            viewModel.inputTemplate = try decoder.decode(InputTemplate.self, from: code)
        case .colorScheme(let schemeCode):
            let codeName = viewModel.squirrelSetting.colorSchemes[schemeCode].codeName
            viewModel.squirrelSetting.colorSchemes[schemeCode] = try decoder.decode(ColorScheme.self, from: code)
            viewModel.squirrelSetting.colorSchemes[schemeCode].codeName = codeName
        case .allSettings:
            viewModel.squirrelSetting = try decoder.decode(SquirrelSetting.self, from: code)
        }
    }
}

#Preview("CodeView", traits: .modifier(SampleData())) {
    CodeView()
}
