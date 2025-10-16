//
//  ConfigData.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/19/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import AppKit
import SwiftUI

enum ColorSpace: String, Codable, CaseIterable {
    case displayP3 = "display_p3"
    case sRGB = "srgb"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let decodedCase = try Self.init(rawValue: container.decode(String.self)) {
            self = decodedCase
        } else {
            self = .sRGB
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

enum StatusMessageType: String, Codable, CaseIterable {
    case long, short, mix
}

struct ColorScheme: Codable, Hashable {
    var codeName: String = "native"
    var name: String?
    var author: String?
    var colorSpace: NSColorSpace = .displayP3

    var backgroundColor: Color = Color(nsColor: .windowBackgroundColor)
    var highlightedPreeditColor: Color?
    var highlightedBackColor: Color? = Color(nsColor: .selectedTextBackgroundColor)
    var preeditBackgroundColor: Color?
    var candidateBackColor: Color?
    var borderColor: Color?

    var textColor: Color = Color(nsColor: .tertiaryLabelColor)
    var highlightedTextColor: Color? = Color(nsColor: .labelColor)
    var candidateTextColor: Color? = Color(nsColor: .secondaryLabelColor)
    var highlightedCandidateTextColor: Color? = Color(nsColor: .labelColor)
    var candidateLabelColor: Color?
    var highlightedCandidateLabelColor: Color?
    var commentTextColor: Color? = Color(nsColor: .tertiaryLabelColor)
    var highlightedCommentTextColor: Color?

    // the following per-color-scheme configurations, if exist, will
    // override configurations with the same name under the global 'style'
    // section
    var linear: Bool?
    var vertical: Bool?
    var translucency: Bool?
    var mutualExclusive: Bool?
    var alpha: Double?
    var cornerRadius: Double?
    var hilitedCornerRadius: Double?
    var surroundingExtraExpansion: Double?
    var borderHeight: Double?
    var borderWidth: Double?
    var linespace: Double?
    var preeditLinespace: Double?
    var baseOffset: Double?
    var shadowSize: Double?

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case author = "author"
        case colorSpace = "color_space"
        case backColor = "back_color"
        case hilitedBackColor = "hilited_back_color"
        case hilitedCandidateBackColor = "hilited_candidate_back_color"
        case preeditBackColor = "preedit_back_color"
        case candidateBackColor = "candidate_back_color"
        case borderColor = "border_color"
        case textColor = "text_color"
        case hilitedTextColor = "hilited_text_color"
        case candidateTextColor = "candidate_text_color"
        case hilitedCandidateTextColor = "hilited_candidate_text_color"
        case labelColor = "label_color"
        case hilitedCandidateLabelColor = "hilited_candidate_label_color"
        case commentTextColor = "comment_text_color"
        case hilitedCommentTextColor = "hilited_comment_text_color"

        // the following per-color-scheme configurations, if exist, will
        // override configurations with the same name under the global 'style'
        // section
        case candidateListLayout = "candidate_list_layout"
        case textOrientation = "text_orientation"
        case translucency = "translucency"
        case mutualExclusive = "mutual_exclusive"
        case alpha = "alpha"
        case cornerRadius = "corner_radius"
        case hilitedCornerRadius = "hilited_corner_radius"
        case surroundingExtraExpansion = "surrounding_extra_expansion"
        case borderHeight = "border_height"
        case borderWidth = "border_width"
        case lineSpacing = "line_spacing"
        case spacing = "spacing"
        case baseOffset = "base_offset"
        case shadowSize = "shadow_size"
    }

    enum CodingError: Error {
        case wrongColor, wrongData
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        switch try container.decodeIfPresent(ColorSpace.self, forKey: .colorSpace) {
        case .displayP3:
            colorSpace = .displayP3
        default:
            colorSpace = .sRGB
        }
        backgroundColor ?= try container.decodeColor(forKey: .backColor, colorSpace: colorSpace)
        highlightedPreeditColor = try container.decodeColorIfPresent(forKey: .hilitedBackColor, colorSpace: colorSpace)
        highlightedBackColor = try container.decodeColorIfPresent(forKey: .hilitedCandidateBackColor, colorSpace: colorSpace)
        preeditBackgroundColor = try container.decodeColorIfPresent(forKey: .preeditBackColor, colorSpace: colorSpace)
        candidateBackColor = try container.decodeColorIfPresent(forKey: .candidateBackColor, colorSpace: colorSpace)
        borderColor = try container.decodeColorIfPresent(forKey: .borderColor, colorSpace: colorSpace)
        textColor ?= try container.decodeColor(forKey: .textColor, colorSpace: colorSpace)
        highlightedTextColor = try container.decodeColorIfPresent(forKey: .hilitedTextColor, colorSpace: colorSpace)
        candidateTextColor = try container.decodeColorIfPresent(forKey: .candidateTextColor, colorSpace: colorSpace)
        highlightedCandidateTextColor = try container.decodeColorIfPresent(forKey: .hilitedCandidateTextColor, colorSpace: colorSpace)
        candidateLabelColor = try container.decodeColorIfPresent(forKey: .labelColor, colorSpace: colorSpace)
        highlightedCandidateLabelColor = try container.decodeColorIfPresent(forKey: .hilitedCandidateLabelColor, colorSpace: colorSpace)
        commentTextColor = try container.decodeColorIfPresent(forKey: .commentTextColor, colorSpace: colorSpace)
        highlightedCommentTextColor = try container.decodeColorIfPresent(forKey: .hilitedCommentTextColor, colorSpace: colorSpace)

        // the following per-color-scheme configurations, if exist, will
        // override configurations with the same name under the global 'style'
        // section
        linear = try container.decodeIfPresent(String.self, forKey: .candidateListLayout).map { $0 == "linear" }
        vertical = try container.decodeIfPresent(String.self, forKey: .textOrientation).map { $0 == "vertical" }
        translucency = try container.decodeIfPresent(Bool.self, forKey: .translucency)
        mutualExclusive = try container.decodeIfPresent(Bool.self, forKey: .mutualExclusive)
        alpha = try container.decodeIfPresent(Double.self, forKey: .alpha).map { max(0.0, min(1.0, $0)) }
        cornerRadius = try container.decodeIfPresent(Double.self, forKey: .cornerRadius).map { max(0.0, $0) }
        hilitedCornerRadius = try container.decodeIfPresent(Double.self, forKey: .hilitedCornerRadius).map { max(0.0, $0) }
        surroundingExtraExpansion = try container.decodeIfPresent(Double.self, forKey: .surroundingExtraExpansion)
        borderHeight = try container.decodeIfPresent(Double.self, forKey: .borderHeight)
        borderWidth = try container.decodeIfPresent(Double.self, forKey: .borderWidth)
        linespace = try container.decodeIfPresent(Double.self, forKey: .lineSpacing)
        preeditLinespace = try container.decodeIfPresent(Double.self, forKey: .spacing)
        baseOffset = try container.decodeIfPresent(Double.self, forKey: .baseOffset)
        shadowSize = try container.decodeIfPresent(Double.self, forKey: .shadowSize).map { max(0.0, $0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(author, forKey: .author)
        switch colorSpace {
        case .displayP3:
            try container.encode(ColorSpace.displayP3, forKey: .colorSpace)
        case .sRGB:
            try container.encode(ColorSpace.sRGB, forKey: .colorSpace)
        default:
            break
        }
        try container.encode(backgroundColor.toString(colorSpace: colorSpace), forKey: .backColor)
        try container.encodeIfPresent(highlightedPreeditColor?.toString(colorSpace: colorSpace), forKey: .hilitedBackColor)
        try container.encodeIfPresent(highlightedBackColor?.toString(colorSpace: colorSpace), forKey: .hilitedCandidateBackColor)
        try container.encodeIfPresent(preeditBackgroundColor?.toString(colorSpace: colorSpace), forKey: .preeditBackColor)
        try container.encodeIfPresent(candidateBackColor?.toString(colorSpace: colorSpace), forKey: .candidateBackColor)
        try container.encodeIfPresent(borderColor?.toString(colorSpace: colorSpace), forKey: .borderColor)
        try container.encode(textColor.toString(colorSpace: colorSpace), forKey: .textColor)
        try container.encodeIfPresent(highlightedTextColor?.toString(colorSpace: colorSpace), forKey: .hilitedTextColor)
        try container.encodeIfPresent(candidateTextColor?.toString(colorSpace: colorSpace), forKey: .candidateTextColor)
        try container.encodeIfPresent(highlightedCandidateTextColor?.toString(colorSpace: colorSpace), forKey: .hilitedCandidateTextColor)
        try container.encodeIfPresent(candidateLabelColor?.toString(colorSpace: colorSpace), forKey: .labelColor)
        try container.encodeIfPresent(highlightedCandidateLabelColor?.toString(colorSpace: colorSpace), forKey: .hilitedCandidateLabelColor)
        try container.encodeIfPresent(commentTextColor?.toString(colorSpace: colorSpace), forKey: .commentTextColor)
        try container.encodeIfPresent(highlightedCommentTextColor?.toString(colorSpace: colorSpace), forKey: .hilitedCommentTextColor)

        // the following per-color-scheme configurations, if exist, will
        // override configurations with the same name under the global 'style'
        // section
        try container.encodeIfPresent(linear.map { $0 ? "linear" : "stacked" }, forKey: .candidateListLayout)
        try container.encodeIfPresent(vertical.map { $0 ? "vertical" : "horizontal" }, forKey: .textOrientation)
        try container.encodeIfPresent(translucency, forKey: .translucency)
        try container.encodeIfPresent(mutualExclusive, forKey: .mutualExclusive)
        try container.encodeIfPresent(alpha, forKey: .alpha)
        try container.encodeIfPresent(cornerRadius, forKey: .cornerRadius)
        try container.encodeIfPresent(hilitedCornerRadius, forKey: .hilitedCornerRadius)
        try container.encodeIfPresent(surroundingExtraExpansion, forKey: .surroundingExtraExpansion)
        try container.encodeIfPresent(borderHeight, forKey: .borderHeight)
        try container.encodeIfPresent(borderWidth, forKey: .borderWidth)
        try container.encodeIfPresent(linespace, forKey: .lineSpacing)
        try container.encodeIfPresent(preeditLinespace, forKey: .spacing)
        try container.encodeIfPresent(baseOffset, forKey: .baseOffset)
        try container.encodeIfPresent(shadowSize, forKey: .shadowSize)
    }
}

struct Style: Codable, Hashable {
    var statusMessageType: StatusMessageType = .mix
    var candidateFormat: String = "[label]. [candidate] [comment]"

    var linear: Bool = false
    var vertical: Bool = false
    var inlinePreedit: Bool = false
    var inlineCandidate: Bool = false
    var translucency: Bool = false
    var mutualExclusive: Bool = false
    var memorizeSize: Bool = false
    var showPaging: Bool = false

    var alpha: Double = 1.0
    var cornerRadius: Double = 0.0
    var hilitedCornerRadius: Double = 0.0
    var surroundingExtraExpansion: Double = 0.0
    var borderHeight: Double = 0.0
    var borderWidth: Double = 0.0
    var linespace: Double = 0.0
    var preeditLinespace: Double = 0.0
    var baseOffset: Double = 0.0
    var shadowSize: Double = 0.0

    var lightScheme: String = "native"
    var darkScheme: String?

    var font: NSFont = .systemFont(ofSize: NSFont.systemFontSize)
    var labelFont: NSFont?
    var commentFont: NSFont?

    var fonts: [NSFont] {
        get {
            decomposeFont(font)
        } set {
            font ?= combineFonts(newValue, size: nil)
        }
    }

    var labelFonts: [NSFont] {
        get {
            decomposeFont(labelFont)
        } set {
            labelFont = combineFonts(newValue, size: nil)
        }
    }

    var commentFonts: [NSFont] {
        get {
            decomposeFont(commentFont)
        } set {
            commentFont = combineFonts(newValue, size: nil)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case statusMessageType = "status_message_type"
        case candidateFormat = "candidate_format"
        case candidateListLayout = "candidate_list_layout"
        case textOrientation = "text_orientation"
        case inlinePreedit = "inline_preedit"
        case inlineCandidate = "inline_candidate"
        case translucency = "translucency"
        case mutualExclusive = "mutual_exclusive"
        case memorizeSize = "memorize_size"
        case showPaging = "showPaging"

        case alpha = "alpha"
        case cornerRadius = "corner_radius"
        case hilitedCornerRadius = "hilited_corner_radius"
        case surroundingExtraExpansion = "surrounding_extra_expansion"
        case borderHeight = "border_height"
        case borderWidth = "border_width"
        case lineSpacing = "line_spacing"
        case spacing = "spacing"
        case baseOffset = "base_offset"
        case shadowSize = "shadow_size"

        case fontFace = "font_face"
        case fontPoint = "font_point"
        case labelFontFace = "label_font_face"
        case labelFontPoint = "label_font_point"
        case commentFontFace = "comment_font_face"
        case commentFontPoint = "comment_font_point"

        case colorScheme = "color_scheme"
        case colorSchemeDark = "color_scheme_dark"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusMessageType ?= try container.decodeIfPresent(StatusMessageType.self, forKey: .statusMessageType)
        candidateFormat ?= try container.decodeIfPresent(String.self, forKey: .candidateFormat)
        linear ?= try container.decodeIfPresent(String.self, forKey: .candidateListLayout).map { $0 == "linear" }
        vertical ?= try container.decodeIfPresent(String.self, forKey: .textOrientation).map { $0 == "vertical" }
        inlinePreedit ?= try container.decodeIfPresent(Bool.self, forKey: .inlinePreedit)
        inlineCandidate ?= try container.decodeIfPresent(Bool.self, forKey: .inlineCandidate)
        translucency ?= try container.decodeIfPresent(Bool.self, forKey: .translucency)
        mutualExclusive ?= try container.decodeIfPresent(Bool.self, forKey: .mutualExclusive)
        memorizeSize ?= try container.decodeIfPresent(Bool.self, forKey: .memorizeSize)
        showPaging ?= try container.decodeIfPresent(Bool.self, forKey: .showPaging)

        alpha ?= try container.decodeIfPresent(Double.self, forKey: .alpha).map { max(0.0, min(1.0, $0)) }
        cornerRadius ?= try container.decodeIfPresent(Double.self, forKey: .cornerRadius).map { max(0.0, $0) }
        hilitedCornerRadius ?= try container.decodeIfPresent(Double.self, forKey: .hilitedCornerRadius).map { max(0.0, $0) }
        surroundingExtraExpansion ?= try container.decodeIfPresent(Double.self, forKey: .surroundingExtraExpansion)
        borderHeight ?= try container.decodeIfPresent(Double.self, forKey: .borderHeight)
        borderWidth ?= try container.decodeIfPresent(Double.self, forKey: .borderWidth)
        linespace ?= try container.decodeIfPresent(Double.self, forKey: .lineSpacing)
        preeditLinespace ?= try container.decodeIfPresent(Double.self, forKey: .spacing)
        baseOffset ?= try container.decodeIfPresent(Double.self, forKey: .baseOffset)
        shadowSize ?= try container.decodeIfPresent(Double.self, forKey: .shadowSize).map { max(0.0, $0) }

        let fontPoint = try container.decodeIfPresent(Double.self, forKey: .fontPoint)
        font ?= try combineFonts(container.decode(String.self, forKey: .fontFace).decodeFonts(), size: fontPoint)
        let labelFontPoint = try container.decodeIfPresent(Double.self, forKey: .labelFontPoint)
        labelFont = try combineFonts(container.decodeIfPresent(String.self, forKey: .labelFontFace)?.decodeFonts() ?? [], size: labelFontPoint)
        let commentFontPoint = try container.decodeIfPresent(Double.self, forKey: .commentFontPoint)
        commentFont = try combineFonts(container.decodeIfPresent(String.self, forKey: .commentFontFace)?.decodeFonts() ?? [], size: commentFontPoint)

        lightScheme = try container.decode(String.self, forKey: .colorScheme)
        darkScheme = try container.decodeIfPresent(String.self, forKey: .colorSchemeDark)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusMessageType, forKey: .statusMessageType)
        try container.encode(candidateFormat, forKey: .candidateFormat)
        try container.encode(linear ? "linear" : "stacked", forKey: .candidateListLayout)
        try container.encode(vertical ? "vertical" : "horizontal", forKey: .textOrientation)
        try container.encode(inlinePreedit, forKey: .inlinePreedit)
        try container.encode(inlineCandidate, forKey: .inlineCandidate)
        try container.encode(translucency, forKey: .translucency)
        try container.encode(mutualExclusive, forKey: .mutualExclusive)
        try container.encode(memorizeSize, forKey: .memorizeSize)
        try container.encode(showPaging, forKey: .showPaging)

        try container.encode(alpha, forKey: .alpha)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try container.encode(hilitedCornerRadius, forKey: .hilitedCornerRadius)
        if surroundingExtraExpansion != 0.0 {
            try container.encode(surroundingExtraExpansion, forKey: .surroundingExtraExpansion)
        }
        try container.encode(borderHeight, forKey: .borderHeight)
        try container.encode(borderWidth, forKey: .borderWidth)
        try container.encode(linespace, forKey: .lineSpacing)
        try container.encode(preeditLinespace, forKey: .spacing)
        if baseOffset != 0.0 {
            try container.encode(baseOffset, forKey: .baseOffset)
        }
        if shadowSize > 0.0 {
            try container.encode(shadowSize, forKey: .shadowSize)
        }

        try container.encode(fonts.map { $0.fontName }.joined(separator: ", "), forKey: .fontFace)
        try container.encode(font.pointSize, forKey: .fontPoint)
        if labelFont != nil {
            try container.encode(labelFonts.map { $0.fontName }.joined(separator: ", "), forKey: .labelFontFace)
        }
        try container.encodeIfPresent(labelFont?.pointSize, forKey: .labelFontPoint)
        if commentFont != nil {
            try container.encode(commentFonts.map { $0.fontName }.joined(separator: ", "), forKey: .commentFontFace)
        }
        try container.encodeIfPresent(commentFont?.pointSize, forKey: .commentFontPoint)

        try container.encode(lightScheme, forKey: .colorScheme)
        try container.encodeIfPresent(darkScheme, forKey: .colorSchemeDark)
    }
}

struct SquirrelSetting: Codable, Hashable {
    var style: Style = Style()
    var colorSchemes: [ColorScheme] = [ColorScheme()]

    private enum CodingKeys: String, CodingKey {
        case style = "style"
        case presetColorSchemes = "preset_color_schemes"
    }

    private struct SchemeKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(intValue: Int) { return nil }
        init(stringValue: String) {
            self.stringValue = stringValue
        }
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        let schemeSuperContainer = try container.superDecoder(forKey: CodingKeys.presetColorSchemes)
        let schemeContainer = try schemeSuperContainer.container(keyedBy: SchemeKeys.self)
        var schemes: [ColorScheme] = []
        for key in schemeContainer.allKeys {
            var scheme = try schemeContainer.decode(ColorScheme.self, forKey: key)
            scheme.codeName = key.stringValue
            schemes.append(scheme)
        }
        colorSchemes = schemes
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        let schemeSuperContainer = container.superEncoder(forKey: .presetColorSchemes)
        var schemeContainer = schemeSuperContainer.container(keyedBy: SchemeKeys.self)
        for scheme in colorSchemes {
            let key = SchemeKeys(stringValue: scheme.codeName)
            try schemeContainer.encode(scheme, forKey: key)
        }
    }
}

struct Candidate: Codable, Hashable {
    var text: String = ""
    var label: String = ""
    var comment: String = ""

    private enum CodingKeys: String, CodingKey {
        case candidate = "candidate"
        case label = "label"
        case comment = "comment"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .candidate)
        label = try container.decode(String.self, forKey: .label)
        comment = try container.decode(String.self, forKey: .comment)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .candidate)
        try container.encode(label, forKey: .label)
        try container.encode(comment, forKey: .comment)
    }
}

struct Preedit: Codable, Hashable {
    var beforeHighlighted: String = ""
    var highlighted: String = ""
    var afterHighlighted: String = ""

    private enum CodingKeys: String, CodingKey {
        case prologue = "prologue"
        case highlighted = "highlighted"
        case postlude = "postlude"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        beforeHighlighted = try container.decode(String.self, forKey: .prologue)
        highlighted = try container.decode(String.self, forKey: .highlighted)
        afterHighlighted = try container.decode(String.self, forKey: .postlude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(beforeHighlighted, forKey: .prologue)
        try container.encode(highlighted, forKey: .highlighted)
        try container.encodeIfPresent(afterHighlighted, forKey: .postlude)
    }
}

struct InputTemplate: Codable, Hashable {
    var preedit: Preedit = Preedit()
    var candidates: [Candidate] = []
    var selection: Int = 0

    private enum CodingKeys: String, CodingKey {
        case preedit = "preedit"
        case candidates = "candidates"
        case selection = "selection"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        preedit = try container.decode(Preedit.self, forKey: .preedit)
        candidates = try container.decode([Candidate].self, forKey: .candidates)
        selection = try container.decode(Int.self, forKey: .selection)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(preedit, forKey: .preedit)
        try container.encode(candidates, forKey: .candidates)
        try container.encode(selection, forKey: .selection)
    }
}

extension Preedit {
    var preedit: String {
        beforeHighlighted + highlighted + "‸" + afterHighlighted
    }
    var selRange: NSRange {
        NSRange(location: beforeHighlighted.utf16.count, length: highlighted.utf16.count)
    }
}

private extension KeyedDecodingContainer {
    func decodeColor(forKey key: Key, colorSpace: NSColorSpace) throws -> Color {
        let colorString = try self.decode(String.self, forKey: key)
        return try colorString.getColor(colorSpace: colorSpace, path: self.codingPath + [key])
    }

    func decodeColorIfPresent(forKey key: Key, colorSpace: NSColorSpace) throws -> Color? {
        guard let colorString = try self.decodeIfPresent(String.self, forKey: key) else { return nil }
        return try colorString.getColor(colorSpace: colorSpace, path: self.codingPath + [key])
    }
}

private extension String {
    func getColor(colorSpace: NSColorSpace, path: [any CodingKey]) throws -> Color {
        let string = self.trimmingCharacters(in: .whitespaces)
        guard !string.isEmpty else {
            throw DecodingError.valueNotFound(Color.self, DecodingError.Context(codingPath: path, debugDescription: "Empty color string"))
        }
        var r = 0, g = 0, b = 0, a = 0xff
        if string.count == 10 {
            // 0xffccbbaa
            let regex = try! NSRegularExpression(pattern: "^0x([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$", options: .caseInsensitive)
            let matches = regex.matches(in: string, options: .init(rawValue: 0), range: NSRange(location: 0, length: string.endIndex.utf16Offset(in: string)))
            if matches.count == 1 {
                r = Int((string as NSString).substring(with: matches[0].range(at: 4)), radix: 16)!
                g = Int((string as NSString).substring(with: matches[0].range(at: 3)), radix: 16)!
                b = Int((string as NSString).substring(with: matches[0].range(at: 2)), radix: 16)!
                a = Int((string as NSString).substring(with: matches[0].range(at: 1)), radix: 16)!
            } else {
                throw DecodingError.typeMismatch(Color.self, DecodingError.Context(codingPath: path, debugDescription: "Invalid color string of 0xAABBGGRR: \(string)"))
            }
        } else if string.count == 8 {
            // 0xccbbaa
            let regex = try! NSRegularExpression(pattern: "^0x([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$", options: .caseInsensitive)
            let matches = regex.matches(in: string, options: .init(rawValue: 0), range: NSRange(location: 0, length: string.endIndex.utf16Offset(in: string)))
            if matches.count == 1 {
                r = Int((string as NSString).substring(with: matches[0].range(at: 3)), radix: 16)!
                g = Int((string as NSString).substring(with: matches[0].range(at: 2)), radix: 16)!
                b = Int((string as NSString).substring(with: matches[0].range(at: 1)), radix: 16)!
            } else {
                throw DecodingError.typeMismatch(Color.self, DecodingError.Context(codingPath: path, debugDescription: "Invalid color string of 0xBBGGRR: \(string)"))
            }
        } else {
            throw DecodingError.typeMismatch(Color.self, DecodingError.Context(codingPath: path, debugDescription: "Invalid color string: \(string)"))
        }
        let nsColor = NSColor(colorSpace: colorSpace, components: [Double(r) / 255, Double(g) / 255, Double(b) / 255, Double(a) / 255], count: 4)
        return Color(nsColor: nsColor)
    }

    func decodeFonts() -> [NSFont] {
        var seenFontFamilies = Set<String>()
        let fontStrings = self.split(separator: ",")
        var fonts = [NSFont]()
        for string in fontStrings {
            let fontName = string.trimmingCharacters(in: .whitespaces)
            if seenFontFamilies.contains(fontName) { continue }
            let fontDescriptor = NSFontDescriptor(fontAttributes: [.name: fontName])
            if let font = NSFont(descriptor: fontDescriptor, size: NSFont.systemFontSize) {
                fonts.append(font)
                seenFontFamilies.insert(fontName)
                continue
            }
        }
        return fonts
    }
}

private extension Color {
    func toString(colorSpace: NSColorSpace) -> String {
        let nsColor = NSColor(self)
        var colorString = "0x"
        if nsColor.alphaComponent < 1 {
            colorString += String(format: "%02X", Int(round(nsColor.alphaComponent * 255)))
        }
        if let colorWithColorspace = nsColor.usingColorSpace(colorSpace) {
            colorString += String(format: "%02X", Int(round(colorWithColorspace.blueComponent * 255)))
            colorString += String(format: "%02X", Int(round(colorWithColorspace.greenComponent * 255)))
            colorString += String(format: "%02X", Int(round(colorWithColorspace.redComponent * 255)))
        }
        return colorString
    }
}

private func decomposeFont(_ font: NSFont?) -> [NSFont] {
    guard let font else { return [] }
    var fonts: [NSFont] = [font]
    if let cascadeList = font.fontDescriptor.object(forKey: .cascadeList) as? [NSFontDescriptor] {
        let cascadeFonts = cascadeList.compactMap { NSFont(descriptor: $0, size: font.pointSize) }
        fonts.append(contentsOf: cascadeFonts)
    }
    return fonts
}

private func combineFonts(_ fonts: [NSFont], size: Double?) -> NSFont? {
    if fonts.count == 0 { return nil }
    let attribute = [NSFontDescriptor.AttributeName.cascadeList: fonts[1...].map { $0.fontDescriptor } ]
    let fontDescriptor = fonts[0].fontDescriptor.addingAttributes(attribute)
    return NSFont(descriptor: fontDescriptor, size: size ?? fonts[0].pointSize)
}

infix operator ?= : AssignmentPrecedence
// swiftlint:disable:next operator_whitespace
func ?=<T>(left: inout T, right: T?) {
    if let right = right {
        left = right
    }
}
// swiftlint:disable:next operator_whitespace
func ?=<T>(left: inout T?, right: T?) {
    if let right = right {
        left = right
    }
}
