//
//  SquirrelTheme.swift
//  Squirrel
//
//  Created by Leo Liu on 5/9/24.
//

import AppKit

final class SquirrelTheme {
    static let offsetHeight: CGFloat = 0
    static let defaultFontSize: CGFloat = NSFont.systemFontSize
    static let showStatusDuration: Double = 1.2

    private(set) var available = true
    private(set) var native = true
    private(set) var memorizeSize = true
    private var colorSpace: NSColorSpace = .sRGB

    var backgroundColor: NSColor = .windowBackgroundColor
    var highlightedPreeditColor: NSColor?
    var highlightedBackColor: NSColor? = .selectedTextBackgroundColor
    var preeditBackgroundColor: NSColor?
    var candidateBackColor: NSColor?
    var borderColor: NSColor?

    private var textColor: NSColor = .tertiaryLabelColor
    private var highlightedTextColor: NSColor = .labelColor
    private var candidateTextColor: NSColor = .secondaryLabelColor
    private var highlightedCandidateTextColor: NSColor = .labelColor
    private var candidateLabelColor: NSColor?
    private var highlightedCandidateLabelColor: NSColor?
    private var commentTextColor: NSColor? = .tertiaryLabelColor
    private var highlightedCommentTextColor: NSColor?

    private(set) var cornerRadius: CGFloat = 0
    private(set) var hilitedCornerRadius: CGFloat = 0
    private(set) var surroundingExtraExpansion: CGFloat = 0
    private(set) var shadowSize: CGFloat = 0
    private(set) var borderWidth: CGFloat = 0
    private(set) var borderHeight: CGFloat = 0
    private(set) var linespace: CGFloat = 0
    private(set) var preeditLinespace: CGFloat = 0
    private(set) var baseOffset: CGFloat = 0
    private(set) var alpha: CGFloat = 1

    private(set) var translucency = false
    private(set) var mutualExclusive = false
    private(set) var linear = false
    private(set) var vertical = false
    private(set) var inlinePreedit = false
    private(set) var inlineCandidate = false
    private(set) var showPaging = false

    private(set) var font: NSFont = .systemFont(ofSize: NSFont.systemFontSize)
    private var _labelFont: NSFont?
    private var _commentFont: NSFont?
    var labelFont: NSFont { _labelFont ?? font }
    var commentFont: NSFont { _commentFont ?? font }
    var fontSize: CGFloat { font.pointSize }
    var labelFontSize: CGFloat { labelFont.pointSize }
    var commentFontSize: CGFloat { commentFont.pointSize }

    private var _candidateFormat = "[label]. [candidate] [comment]"
    private(set) var statusMessageType: StatusMessageType = .mix

    private(set) lazy var attrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: candidateTextColor,
        .font: font,
        .baselineOffset: baseOffset
    ]
    private(set) lazy var highlightedAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: highlightedCandidateTextColor,
        .font: font,
        .baselineOffset: baseOffset
    ]
    private(set) lazy var labelAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: candidateLabelColor ?? self.candidateTextColor.blended(withFraction: 2/3, of: self.backgroundColor)!,
        .font: labelFont,
        .baselineOffset: baseOffset + (!vertical ? (font.pointSize - labelFont.pointSize) / 2.5 : 0)
    ]
    private(set) lazy var labelHighlightedAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: highlightedCandidateLabelColor ?? highlightedCandidateTextColor.blended(withFraction: 2/3, of: highlightedBackColor ?? .gray)!,
        .font: labelFont,
        .baselineOffset: baseOffset + (!vertical ? (font.pointSize - labelFont.pointSize) / 2.5 : 0)
    ]
    private(set) lazy var commentAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: commentTextColor ?? candidateTextColor,
        .font: commentFont,
        .baselineOffset: baseOffset + (!vertical ? (font.pointSize - commentFont.pointSize) / 2.5 : 0)
    ]
    private(set) lazy var commentHighlightedAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: highlightedCommentTextColor ?? highlightedCandidateTextColor,
        .font: commentFont,
        .baselineOffset: baseOffset + (!vertical ? (font.pointSize - commentFont.pointSize) / 2.5 : 0)
    ]
    private(set) lazy var preeditAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: textColor,
        .font: font,
        .baselineOffset: baseOffset
    ]
    private(set) lazy var preeditHighlightedAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: highlightedTextColor,
        .font: font,
        .baselineOffset: baseOffset
    ]

    private(set) lazy var firstParagraphStyle: NSParagraphStyle = {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = linespace / 2
        style.paragraphSpacingBefore = preeditLinespace / 2 + hilitedCornerRadius / 2
        return style as NSParagraphStyle
    }()
    private(set) lazy var paragraphStyle: NSParagraphStyle = {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = linespace / 2
        style.paragraphSpacingBefore = linespace / 2
        return style as NSParagraphStyle
    }()
    private(set) lazy var preeditParagraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = preeditLinespace / 2 + hilitedCornerRadius / 2
        style.lineSpacing = linespace
        return style as NSParagraphStyle
    }()
    private(set) lazy var edgeInset: NSSize = if self.vertical {
        NSSize(width: borderHeight + cornerRadius, height: borderWidth + cornerRadius)
    } else {
        NSSize(width: borderWidth + cornerRadius, height: borderHeight + cornerRadius)
    }
    private(set) lazy var borderLineWidth: CGFloat = min(borderHeight, borderWidth)
    private(set) var candidateFormat: String {
        get {
            _candidateFormat
        } set {
            var newTemplate = newValue
            if newTemplate.contains(/%@/) {
                newTemplate.replace(/%@/, with: "[candidate] [comment]")
            }
            if newTemplate.contains(/%c/) {
                newTemplate.replace(/%c/, with: "[label]")
            }
            _candidateFormat = newTemplate
        }
    }
    var pagingOffset: CGFloat {
        if showPaging {
            labelFontSize * 1.5
        } else {
            0
        }
    }

    init(setting: SquirrelSetting, colorScheme: String) {
        let style = setting.style

        linear = style.linear
        vertical = style.vertical
        inlinePreedit = style.inlinePreedit
        inlineCandidate = style.inlineCandidate
        translucency = style.translucency
        mutualExclusive = style.mutualExclusive
        memorizeSize = style.memorizeSize
        showPaging = style.showPaging

        statusMessageType = style.statusMessageType
        candidateFormat = style.candidateFormat

        alpha = style.alpha
        cornerRadius = style.cornerRadius
        hilitedCornerRadius = style.hilitedCornerRadius
        surroundingExtraExpansion = style.surroundingExtraExpansion
        borderHeight = style.borderHeight
        borderWidth = style.borderWidth
        linespace = style.linespace
        preeditLinespace = style.preeditLinespace
        baseOffset = style.baseOffset
        shadowSize = style.shadowSize

        font = style.font
        _labelFont = style.labelFont
        _commentFont = style.commentFont

        var scheme: ColorScheme?
        for _scheme in setting.colorSchemes where _scheme.codeName == colorScheme {
            scheme = _scheme
            break
        }
        if let scheme, scheme.codeName != "native" {
            native = false
            colorSpace = scheme.colorSpace
            backgroundColor = NSColor(scheme.backgroundColor)
            highlightedPreeditColor = scheme.highlightedPreeditColor.map(NSColor.init)
            highlightedBackColor = scheme.highlightedBackColor.map(NSColor.init) ?? highlightedPreeditColor
            preeditBackgroundColor = scheme.preeditBackgroundColor.map(NSColor.init)
            candidateBackColor = scheme.candidateBackColor.map(NSColor.init)
            borderColor = scheme.candidateBackColor.map(NSColor.init)

            textColor = NSColor(scheme.textColor)
            highlightedTextColor = scheme.highlightedTextColor.map(NSColor.init) ?? textColor
            candidateTextColor = scheme.candidateTextColor.map(NSColor.init) ?? textColor
            highlightedCandidateTextColor = scheme.highlightedCandidateTextColor.map(NSColor.init) ?? highlightedTextColor
            candidateLabelColor = scheme.candidateLabelColor.map(NSColor.init)
            highlightedCandidateLabelColor = scheme.highlightedCandidateLabelColor.map(NSColor.init)
            commentTextColor = scheme.commentTextColor.map(NSColor.init)
            highlightedCommentTextColor = scheme.highlightedCommentTextColor.map(NSColor.init)

            // the following per-color-scheme configurations, if exist, will
            // override configurations with the same name under the global 'style'
            // section
            linear ?= scheme.linear
            vertical ?= scheme.vertical
            translucency ?= scheme.translucency
            mutualExclusive ?= scheme.mutualExclusive

            alpha ?= scheme.alpha.map { CGFloat($0) }
            cornerRadius ?= scheme.cornerRadius.map { CGFloat($0) }
            hilitedCornerRadius ?= scheme.hilitedCornerRadius.map { CGFloat($0) }
            surroundingExtraExpansion ?= scheme.surroundingExtraExpansion.map { CGFloat($0) }
            borderHeight ?= scheme.borderHeight.map { CGFloat($0) }
            borderWidth ?= scheme.borderWidth.map { CGFloat($0) }
            linespace ?= scheme.linespace.map { CGFloat($0) }
            preeditLinespace ?= scheme.preeditLinespace.map { CGFloat($0) }
            baseOffset ?= scheme.baseOffset.map { CGFloat($0) }
            shadowSize ?= scheme.shadowSize.map { CGFloat($0) }
        }
    }
}
