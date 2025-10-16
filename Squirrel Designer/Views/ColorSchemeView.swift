//
//  ColorSchemeView.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/25/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI

struct ColorSchemeView: View {
    let index: Int
    @Environment(ViewModel.self) var viewModel
    private var _colorScheme: Binding<ColorScheme> {
        Binding(get: {
            if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
                viewModel.squirrelSetting.colorSchemes[index]
            } else {
                ColorScheme()
            }
        }, set: { newValue in
            if index >= 0 && index < viewModel.squirrelSetting.colorSchemes.count {
                viewModel.squirrelSetting.colorSchemes[index] = newValue
                viewModel.saveTask?.cancel()
                viewModel.saveTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                    viewModel.save()
                }
            }
        })
    }
    private var colorScheme: ColorScheme {
        _colorScheme.wrappedValue
    }

    var body: some View {
        let view = Form {
            metadataSection
            backgroundColorsSection
            textColorsSection
            optionalSection
        }
        .formStyle(.grouped)
        .navigationTitle("COLOR_SCHEME:\(colorScheme.codeName)")
        if let name = colorScheme.name {
            view
                .navigationSubtitle(name)
        } else {
            view
        }
    }

    var metadataSection: some View {
        Section {
            DeletableRow(optional: _colorScheme.name) {
                TextField("SCHEME_READABLE_NAME", text: _colorScheme.name.unwrap(default: ""))
            }
            DeletableRow(optional: _colorScheme.author) {
                TextField("SCHEME_AUTHOR", text: _colorScheme.author.unwrap(default: ""))
            }
            StaticRow {
                Picker("COLOR_SPACE", selection: _colorScheme.colorSpace) {
                    ForEach([NSColorSpace.displayP3, .sRGB], id: \.self) { colorSpace in
                        switch colorSpace {
                        case .displayP3:
                            Text("DISPLAY_P3")
                        case .sRGB:
                            Text("SRGB")
                        default:
                            Text("UNKNOWN_COLORSPACE")
                        }
                    }
                }
            }
        } header: {
            AddableTitle(title: "METADATA", show: [colorScheme.name, colorScheme.author].reduce(false, { $0 || $1 == nil })) {
                Menu {
                    if colorScheme.name == nil {
                        Button("ADD_READABLE_NAME") {
                            _colorScheme.wrappedValue.name = String(localized: "NEW_NAME")
                        }
                    }
                    if colorScheme.author == nil {
                        Button("ADD_AUTHOR") {
                            _colorScheme.wrappedValue.author = String(localized: "NEW_AUTHOR")
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }

    var backgroundColorsSection: some View {
        Section {
            LazyVGrid(columns: viewModel.gridColumns, spacing: 20) {
                StaticRow {
                    ColorPicker("BACKGROUND_COLOR", selection: _colorScheme.backgroundColor)
                }
                DeletableRow(optional: _colorScheme.highlightedPreeditColor) {
                    ColorPicker("HILIT_PREEDIT_BACK_COLOR", selection: _colorScheme.highlightedPreeditColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.highlightedBackColor) {
                    ColorPicker("HILIT_CAND_BACK_COLOR", selection: _colorScheme.highlightedBackColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.preeditBackgroundColor) {
                    ColorPicker("PREEDIT_BACK_COLOR", selection: _colorScheme.preeditBackgroundColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.candidateBackColor) {
                    ColorPicker("CAND_BACK_COLOR", selection: _colorScheme.candidateBackColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.borderColor) {
                    ColorPicker("BORDER_COLOR", selection: _colorScheme.borderColor.unwrap(default: .clear))
                }
            }
        } header: {
            AddableTitle(title: "BACKGROUND_COLORS", show: [colorScheme.highlightedPreeditColor, colorScheme.highlightedBackColor, colorScheme.preeditBackgroundColor, colorScheme.candidateBackColor, colorScheme.borderColor].reduce(false, { $0 || $1 == nil })) {
                Menu {
                    if colorScheme.highlightedPreeditColor == nil {
                        Button("ADD_HILIT_PREEDIT_BACK_COLOR") {
                            _colorScheme.wrappedValue.highlightedPreeditColor = colorScheme.preeditBackgroundColor ?? .clear
                        }
                    }
                    if colorScheme.highlightedBackColor == nil {
                        Button("ADD_HILIT_CAND_BACK_COLOR") {
                            _colorScheme.wrappedValue.highlightedBackColor = .accentColor
                        }
                    }
                    if colorScheme.preeditBackgroundColor == nil {
                        Button("ADD_PREEDIT_BACK_COLOR") {
                            _colorScheme.wrappedValue.preeditBackgroundColor = .clear
                        }
                    }
                    if colorScheme.candidateBackColor == nil {
                        Button("ADD_CAND_BACK_COLOR") {
                            _colorScheme.wrappedValue.candidateBackColor = .clear
                        }
                    }
                    if colorScheme.borderColor == nil {
                        Button("ADD_BORDER_COLOR") {
                            _colorScheme.wrappedValue.borderColor = .clear
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }

    var textColorsSection: some View {
        Section {
            LazyVGrid(columns: viewModel.gridColumns, spacing: 20) {
                StaticRow {
                    ColorPicker("TEXT_COLOR", selection: _colorScheme.textColor)
                }
                DeletableRow(optional: _colorScheme.highlightedTextColor) {
                    ColorPicker("HILIT_TEXT_COLOR", selection: _colorScheme.highlightedTextColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.candidateTextColor) {
                    ColorPicker("CAND_TEXT_COLOR", selection: _colorScheme.candidateTextColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.highlightedCandidateTextColor) {
                    ColorPicker("HILIT_CAND_TEXT_COLOR", selection: _colorScheme.highlightedCandidateTextColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.candidateLabelColor) {
                    ColorPicker("CAND_LABEL_COLOR", selection: _colorScheme.candidateLabelColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.highlightedCandidateLabelColor) {
                    ColorPicker("HILIT_CAND_LABEL_COLOR", selection: _colorScheme.highlightedCandidateLabelColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.commentTextColor) {
                    ColorPicker("CAND_COMMENT_COLOR", selection: _colorScheme.commentTextColor.unwrap(default: .clear))
                }
                DeletableRow(optional: _colorScheme.highlightedCommentTextColor) {
                    ColorPicker("HILIT_CAND_COMMENT_COLOR", selection: _colorScheme.highlightedCommentTextColor.unwrap(default: .clear))
                }
            }
        } header: {
            AddableTitle(title: "TEXT_COLORS", show: [
                colorScheme.highlightedTextColor, colorScheme.candidateTextColor, colorScheme.highlightedCandidateTextColor,
                colorScheme.candidateLabelColor, colorScheme.highlightedCandidateLabelColor, colorScheme.commentTextColor, colorScheme.highlightedCommentTextColor
            ].reduce(false, { $0 || $1 == nil })) {
                Menu {
                    if colorScheme.highlightedTextColor == nil {
                        Button("ADD_HILIT_TEXT_COLOR") {
                            _colorScheme.wrappedValue.highlightedTextColor = colorScheme.textColor
                        }
                    }
                    if colorScheme.candidateTextColor == nil {
                        Button("ADD_CAND_TEXT_COLOR") {
                            _colorScheme.wrappedValue.candidateTextColor = colorScheme.textColor
                        }
                    }
                    if colorScheme.highlightedCandidateTextColor == nil {
                        Button("ADD_HILIT_CAND_TEXT_COLOR") {
                            _colorScheme.wrappedValue.highlightedCandidateTextColor = colorScheme.highlightedTextColor ?? colorScheme.textColor
                        }
                    }
                    if colorScheme.candidateLabelColor == nil {
                        Button("ADD_CAND_LABEL_COLOR") {
                            _colorScheme.wrappedValue.candidateLabelColor = colorScheme.candidateTextColor ?? colorScheme.textColor
                        }
                    }
                    if colorScheme.highlightedCandidateLabelColor == nil {
                        Button("ADD_HILIT_CAND_LABEL_COLOR") {
                            _colorScheme.wrappedValue.highlightedCandidateLabelColor = colorScheme.highlightedCandidateTextColor ?? colorScheme.highlightedTextColor ?? colorScheme.textColor
                        }
                    }
                    if colorScheme.commentTextColor == nil {
                        Button("ADD_CAND_COMMENT_COLOR") {
                            _colorScheme.wrappedValue.commentTextColor = (colorScheme.candidateTextColor ?? colorScheme.textColor).mix(with: colorScheme.backgroundColor, by: 2/3)
                        }
                    }
                    if colorScheme.highlightedCommentTextColor == nil {
                        Button("ADD_HILIT_CAND_COMMENT_COLOR") {
                            _colorScheme.wrappedValue.highlightedCommentTextColor = (colorScheme.highlightedCandidateTextColor ?? colorScheme.highlightedTextColor ?? colorScheme.textColor).mix(with: colorScheme.backgroundColor, by: 2/3)
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }

    var optionalSection: some View {
        Section {
            if [colorScheme.linear, colorScheme.vertical, colorScheme.translucency, colorScheme.mutualExclusive].reduce(false, { $0 || $1 != nil }) || [
                colorScheme.alpha, colorScheme.cornerRadius, colorScheme.hilitedCornerRadius, colorScheme.surroundingExtraExpansion,
                colorScheme.borderHeight, colorScheme.borderWidth, colorScheme.linespace, colorScheme.preeditLinespace, colorScheme.baseOffset, colorScheme.shadowSize
            ].reduce(false, { $0 || $1 != nil }) {
                LazyVGrid(columns: viewModel.gridColumns, spacing: 20) {
                    DeletableRow(optional: _colorScheme.linear) {
                        Toggle("IS_LINEAR", isOn: _colorScheme.linear.unwrap(default: viewModel.squirrelSetting.style.linear))
                    }
                    DeletableRow(optional: _colorScheme.vertical) {
                        Toggle("IS_VERTICAL", isOn: _colorScheme.vertical.unwrap(default: viewModel.squirrelSetting.style.vertical))
                    }
                    DeletableRow(optional: _colorScheme.translucency) {
                        Toggle("IS_TRANSLUCENT", isOn: _colorScheme.translucency.unwrap(default: viewModel.squirrelSetting.style.translucency))
                    }
                    DeletableRow(optional: _colorScheme.mutualExclusive) {
                        Toggle("IS_MUTUAL_EXCLUSIVE", isOn: _colorScheme.mutualExclusive.unwrap(default: viewModel.squirrelSetting.style.mutualExclusive))
                    }
                    DeletableRow(optional: _colorScheme.alpha) {
                        SliderCell("ALPHA", value: _colorScheme.alpha.unwrap(default: viewModel.squirrelSetting.style.alpha), in: 0...1)
                    }
                    DeletableRow(optional: _colorScheme.cornerRadius) {
                        NemericalCell("CORNER_RADIUS", value: _colorScheme.cornerRadius.unwrap(default: viewModel.squirrelSetting.style.cornerRadius)) { max(0, $0) }
                    }
                    DeletableRow(optional: _colorScheme.hilitedCornerRadius) {
                        NemericalCell("HILIT_CORNER_RADIUS", value: _colorScheme.hilitedCornerRadius.unwrap(default: viewModel.squirrelSetting.style.hilitedCornerRadius)) { max(0, $0) }
                    }
                    DeletableRow(optional: _colorScheme.surroundingExtraExpansion) {
                        NemericalCell("SUR_EXTRA_EXPAN", value: _colorScheme.surroundingExtraExpansion.unwrap(default: viewModel.squirrelSetting.style.surroundingExtraExpansion))
                    }
                    DeletableRow(optional: _colorScheme.borderHeight) {
                        NemericalCell("BORDER_HEIGHT", value: _colorScheme.borderHeight.unwrap(default: viewModel.squirrelSetting.style.borderHeight))
                    }
                    DeletableRow(optional: _colorScheme.borderWidth) {
                        NemericalCell("BORDER_WIDTH", value: _colorScheme.borderWidth.unwrap(default: viewModel.squirrelSetting.style.borderWidth))
                    }
                    DeletableRow(optional: _colorScheme.linespace) {
                        NemericalCell("CAND_LINESPACE", value: _colorScheme.linespace.unwrap(default: viewModel.squirrelSetting.style.linespace))
                    }
                    DeletableRow(optional: _colorScheme.preeditLinespace) {
                        NemericalCell("PREEDIT_LINESPACE", value: _colorScheme.preeditLinespace.unwrap(default: viewModel.squirrelSetting.style.preeditLinespace))
                    }
                    DeletableRow(optional: _colorScheme.baseOffset) {
                        NemericalCell("FONT_BASE_OFFSET", value: _colorScheme.baseOffset.unwrap(default: viewModel.squirrelSetting.style.baseOffset))
                    }
                    DeletableRow(optional: _colorScheme.shadowSize) {
                        NemericalCell("SHADOW_SIZE", value: _colorScheme.shadowSize.unwrap(default: viewModel.squirrelSetting.style.shadowSize)) { max(0, $0) }
                    }
                }
            } else {
                Text("NO_ROW")
                    .frame(maxWidth: .infinity)
            }
        } header: {
            AddableTitle(title: "OPTIONAL_VALUES", show: [colorScheme.linear, colorScheme.vertical, colorScheme.translucency, colorScheme.mutualExclusive].reduce(false, { $0 || $1 == nil }) || [
                colorScheme.alpha, colorScheme.cornerRadius, colorScheme.hilitedCornerRadius, colorScheme.surroundingExtraExpansion,
                colorScheme.borderHeight, colorScheme.borderWidth, colorScheme.linespace, colorScheme.preeditLinespace, colorScheme.baseOffset, colorScheme.shadowSize
            ].reduce(false, { $0 || $1 == nil })) {
                Menu {
                    if colorScheme.linear == nil {
                        Button("ADD_LINEAR") {
                            _colorScheme.wrappedValue.linear = viewModel.squirrelSetting.style.linear
                        }
                    }
                    if colorScheme.vertical == nil {
                        Button("ADD_VERTICAL") {
                            _colorScheme.wrappedValue.vertical = viewModel.squirrelSetting.style.vertical
                        }
                    }
                    if colorScheme.translucency == nil {
                        Button("ADD_TRANSLUCENT") {
                            _colorScheme.wrappedValue.translucency = viewModel.squirrelSetting.style.translucency
                        }
                    }
                    if colorScheme.mutualExclusive == nil {
                        Button("ADD_IS_MUTUAL_EXCLUSIVE") {
                            _colorScheme.wrappedValue.mutualExclusive = viewModel.squirrelSetting.style.mutualExclusive
                        }
                    }
                    if colorScheme.alpha == nil {
                        Button("ADD_ALPHA") {
                            _colorScheme.wrappedValue.alpha = viewModel.squirrelSetting.style.alpha
                        }
                    }
                    if colorScheme.cornerRadius == nil {
                        Button("ADD_CORNER_RADIUS") {
                            _colorScheme.wrappedValue.cornerRadius = viewModel.squirrelSetting.style.cornerRadius
                        }
                    }
                    if colorScheme.hilitedCornerRadius == nil {
                        Button("ADD_HILIT_CORNER_RADIUS") {
                            _colorScheme.wrappedValue.hilitedCornerRadius = viewModel.squirrelSetting.style.hilitedCornerRadius
                        }
                    }
                    if colorScheme.surroundingExtraExpansion == nil {
                        Button("ADD_SUR_EXTRA_EXPAN") {
                            _colorScheme.wrappedValue.surroundingExtraExpansion = viewModel.squirrelSetting.style.surroundingExtraExpansion
                        }
                    }
                    if colorScheme.borderHeight == nil {
                        Button("ADD_BORDER_HEIGHT") {
                            _colorScheme.wrappedValue.borderHeight = viewModel.squirrelSetting.style.borderHeight
                        }
                    }
                    if colorScheme.borderWidth == nil {
                        Button("ADD_BORDER_WIDTH") {
                            _colorScheme.wrappedValue.borderWidth = viewModel.squirrelSetting.style.borderWidth
                        }
                    }
                    if colorScheme.linespace == nil {
                        Button("ADD_CAND_LINESPACE") {
                            _colorScheme.wrappedValue.linespace = viewModel.squirrelSetting.style.linespace
                        }
                    }
                    if colorScheme.preeditLinespace == nil {
                        Button("ADD_PREEDIT_LINESPACE") {
                            _colorScheme.wrappedValue.preeditLinespace = viewModel.squirrelSetting.style.preeditLinespace
                        }
                    }
                    if colorScheme.baseOffset == nil {
                        Button("ADD_FONT_BASE_OFFSET") {
                            _colorScheme.wrappedValue.baseOffset = viewModel.squirrelSetting.style.baseOffset
                        }
                    }
                    if colorScheme.shadowSize == nil {
                        Button("ADD_SHADOW_SIZE") {
                            _colorScheme.wrappedValue.shadowSize = viewModel.squirrelSetting.style.shadowSize
                        }
                    }
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
            }
        }
    }
}

#Preview("ColorSchemeView", traits: .modifier(SampleData())) {
    ColorSchemeView(index: 0)
}
