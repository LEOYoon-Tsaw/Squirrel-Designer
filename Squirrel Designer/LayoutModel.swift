//
//  LayoutModel.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import AppKit

class SquirrelLayout {
    static var template: String?
    
    var name: String = "customized_color_scheme"
    var backgroundColor: NSColor? = .windowBackgroundColor
    var stripColor: NSColor?
    var highlightedStripColor: NSColor? = .selectedTextBackgroundColor
    var highlightedPreeditColor: NSColor?
    var preeditBackgroundColor: NSColor?
    var borderColor: NSColor?
    
    var cornerRadius: CGFloat = 0
    var hilitedCornerRadius: CGFloat = 0
    var surroundingExtraExpansion: CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderHeight: CGFloat = 0
    var linespace: CGFloat = 0
    var preeditLinespace: CGFloat = 0
    var baseOffset: CGFloat = 0
    var shadowSize: CGFloat = 0
    var alpha: CGFloat = 1
    
    var linear = false
    var vertical = false
    var inlinePreedit = false
    var isDisplayP3 = true
    var translucency = false
    var mutualExclusive = false
    
    var fonts: Array<NSFont> = [NSFont.userFont(ofSize: 15)!]
    var labelFonts = Array<NSFont>()
    var commentFonts = Array<NSFont>()
    var textColor: NSColor? = .disabledControlTextColor
    var highlightedTextColor: NSColor? = .controlTextColor
    var candidateTextColor: NSColor? = .controlTextColor
    var highlightedCandidateTextColor: NSColor? = .selectedControlTextColor
    var candidateLabelColor: NSColor?
    var highlightedCandidateLabelColor: NSColor?
    var commentTextColor: NSColor? = .disabledControlTextColor
    var highlightedCommentTextColor: NSColor?
    
    init(new: Bool) {
        if !new, let template = Self.template {
            self.decode(from: template)
        }
    }
    
    var font: NSFont? {
        return combineFonts(fonts)
    }
    var labelFont: NSFont? {
        return combineFonts(labelFonts)
    }
    var commentFont: NSFont? {
        return combineFonts(commentFonts)
    }
    var attrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: candidateTextColor!,
         .font: font!,
         .baselineOffset: baseOffset]
    }
    var highlightedAttrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: highlightedCandidateTextColor!,
         .font: font!,
         .baselineOffset: baseOffset]
    }
    var commentAttrs: [NSAttributedString.Key : Any] {
        return [.foregroundColor: commentTextColor!,
         .font: commentFont ?? font!,
         .baselineOffset: baseOffset]
    }
    var commentHighlightedAttrs: [NSAttributedString.Key : Any] {
        return [.foregroundColor: highlightedCommentTextColor ?? commentTextColor!,
         .font: commentFont ?? font!,
         .baselineOffset: baseOffset]
    }
    var preeditAttrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: textColor!,
         .font: font!,
         .baselineOffset: baseOffset]
    }
    var preeditHighlightedAttrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: highlightedTextColor!,
         .font: font!,
         .baselineOffset: baseOffset]
    }
    var labelAttrs: [NSAttributedString.Key : Any] {
        return [.foregroundColor: candidateLabelColor ?? blendColor(foregroundColor: self.candidateTextColor!, backgroundColor: self.backgroundColor),
         .font: labelFont ?? font!,
         .baselineOffset: baseOffset]
    }
    var labelHighlightedAttrs: [NSAttributedString.Key : Any] {
        return [.foregroundColor: highlightedCandidateLabelColor ?? blendColor(foregroundColor: highlightedCandidateTextColor!, backgroundColor: highlightedStripColor),
         .font: labelFont ?? font!,
         .baselineOffset: baseOffset]
    }

    var firstParagraphStyle: NSParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = linespace / 2
        style.paragraphSpacingBefore = preeditLinespace / 2 + hilitedCornerRadius / 2
        return style as NSParagraphStyle
    }
    var paragraphStyle: NSParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = linespace / 2
        style.paragraphSpacingBefore = linespace / 2
        return style as NSParagraphStyle
    }
    var preeditParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = preeditLinespace / 2 + hilitedCornerRadius / 2
        return style as NSParagraphStyle
    }
    
    var edgeInset: NSSize {
        if (self.vertical) {
            return NSMakeSize(borderHeight + cornerRadius, borderWidth + cornerRadius)
        } else {
            return NSMakeSize(borderWidth + cornerRadius, borderHeight + cornerRadius)
        }
    }
    var borderLineWidth: CGFloat {
        return min(borderHeight, borderWidth)
    }

    func combineFonts(_ fonts: Array<NSFont>) -> NSFont? {
        if fonts.count == 0 { return nil }
        if fonts.count == 1 { return fonts[0] }
        let attribute = [NSFontDescriptor.AttributeName.cascadeList: fonts[1...].map { $0.fontDescriptor } ]
        let fontDescriptor = fonts[0].fontDescriptor.addingAttributes(attribute)
        return NSFont.init(descriptor: fontDescriptor, size: fonts[0].pointSize)
    }
    func decodeFonts(from fontString: String, size: CGFloat) -> Array<NSFont> {
        var seenFontFamilies = Set<String>()
        let fontStrings = fontString.split(separator: ",")
        var fonts = Array<NSFont>()
        for string in fontStrings {
            let trimedString = string.trimmingCharacters(in: .whitespaces)
            if let fontFamilyName = trimedString.split(separator: "-").first.map({String($0)}) {
                if seenFontFamilies.contains(fontFamilyName) {
                    continue
                } else {
                    seenFontFamilies.insert(fontFamilyName)
                }
            } else {
                if seenFontFamilies.contains(trimedString) {
                    continue
                } else {
                    seenFontFamilies.insert(trimedString)
                }
            }
            if let validFont = NSFont(name: String(trimedString), size: size) {
                fonts.append(validFont)
            }
        }
        return fonts
    }
    func encode() -> String {
        func colorToString(_ color: NSColor, inDisplayP3: Bool) -> String {
            var colorString = "0x"
            if color.alphaComponent < 1 {
                colorString += String(format:"%02X", Int(round(color.alphaComponent * 255)))
            }
            let colorWithColorspace: NSColor
            if inDisplayP3 {
                colorWithColorspace = color.usingColorSpace(NSColorSpace.displayP3)!
            } else {
                colorWithColorspace = color.usingColorSpace(NSColorSpace.sRGB)!
            }
            colorString += String(format:"%02X", Int(round(colorWithColorspace.blueComponent * 255)))
            colorString += String(format:"%02X", Int(round(colorWithColorspace.greenComponent * 255)))
            colorString += String(format:"%02X", Int(round(colorWithColorspace.redComponent * 255)))
            return colorString
        }
        
        var encoded = ""
        if !name.isEmpty {
            encoded += "name: \"\(name)\"\n"
        }
        let fontNames = fonts.map { $0.fontName.trimmingCharacters(in: .whitespaces) }.joined(separator: ", ")
        encoded += "font_face: \"\(fontNames)\"\n"
        encoded += "font_point: \(fonts[0].pointSize)\n"
        if !labelFonts.isEmpty {
            let fontNames = labelFonts.map { $0.fontName.trimmingCharacters(in: .whitespaces) }.joined(separator: ", ")
            encoded += "label_font_face: \"\(fontNames)\"\n"
            encoded += "label_font_point: \(labelFonts[0].pointSize)\n"
        }
        if !commentFonts.isEmpty {
            let fontNames = commentFonts.map { $0.fontName.trimmingCharacters(in: .whitespaces) }.joined(separator: ", ")
            encoded += "comment_font_face: \"\(fontNames)\"\n"
            encoded += "comment_font_point: \(commentFonts[0].pointSize)\n"
        }
        encoded += "candidate_list_layout: \(linear ? "linear" : "stacked")\n"
        encoded += "text_orientation: \(vertical ? "vertical" : "horizontal")\n"
        encoded += "inline_preedit: \(inlinePreedit ? "true" : "false")\n"
        if translucency {
            encoded += "translucency: \(translucency)\n"
        }
        if mutualExclusive {
            encoded += "mutual_exclusive: \(mutualExclusive)\n"
        }
        if cornerRadius != 0 {
            encoded += "corner_radius: \(cornerRadius)\n"
        }
        if hilitedCornerRadius != 0 {
            encoded += "hilited_corner_radius: \(hilitedCornerRadius)\n"
        }
        if surroundingExtraExpansion != 0 {
            encoded += "surrounding_extra_expansion: \(surroundingExtraExpansion)\n"
        }
        if borderHeight != 0 {
            encoded += "border_height: \(borderHeight)\n"
        }
        if borderWidth != 0 {
            encoded += "border_width: \(borderWidth)\n"
        }
        if linespace != 0 {
            encoded += "line_spacing: \(linespace)\n"
        }
        if preeditLinespace != 0 {
            encoded += "spacing: \(preeditLinespace)\n"
        }
        if baseOffset != 0 {
            encoded += "base_offset: \(baseOffset)\n"
        }
        if alpha != 1 {
            encoded += "alpha: \(alpha)\n"
        }
        if shadowSize > 0 {
            encoded += "shadow_size: \(shadowSize)\n"
        }
        
        //Colors
        if isDisplayP3 {
            encoded += "color_space: display_p3\n"
        } else {
            encoded += "color_space: srgb\n"
        }
        encoded += "back_color: \(colorToString(backgroundColor!, inDisplayP3: isDisplayP3))\n"
        if borderColor != nil {
            encoded += "border_color: \(colorToString(borderColor!, inDisplayP3: isDisplayP3))\n"
        }
        if stripColor != nil {
            encoded += "candidate_back_color: \(colorToString(stripColor!, inDisplayP3: isDisplayP3))\n"
        }
        encoded += "candidate_text_color: \(colorToString(candidateTextColor!, inDisplayP3: isDisplayP3))\n"
        encoded += "comment_text_color: \(colorToString(commentTextColor!, inDisplayP3: isDisplayP3))\n"
        if candidateLabelColor != nil {
            encoded += "label_color: \(colorToString(candidateLabelColor!, inDisplayP3: isDisplayP3))\n"
        }
        encoded += "hilited_candidate_back_color: \(colorToString(highlightedStripColor!, inDisplayP3: isDisplayP3))\n"
        encoded += "hilited_candidate_text_color: \(colorToString(highlightedCandidateTextColor!, inDisplayP3: isDisplayP3))\n"
        if highlightedCommentTextColor != nil {
            encoded += "hilited_comment_text_color: \(colorToString(highlightedCommentTextColor!, inDisplayP3: isDisplayP3))\n"
        }
        if highlightedCandidateLabelColor != nil {
            encoded += "hilited_candidate_label_color: \(colorToString(highlightedCandidateLabelColor!, inDisplayP3: isDisplayP3))\n"
        }
        if preeditBackgroundColor != nil {
            encoded += "preedit_back_color: \(colorToString(preeditBackgroundColor!, inDisplayP3: isDisplayP3))\n"
        }
        encoded += "text_color: \(colorToString(textColor!, inDisplayP3: isDisplayP3))\n"
        if highlightedPreeditColor != nil {
            encoded += "hilited_back_color: \(colorToString(highlightedPreeditColor!, inDisplayP3: isDisplayP3))\n"
        }
        encoded += "hilited_text_color: \(colorToString(highlightedTextColor!, inDisplayP3: isDisplayP3))\n"
        let _ = encoded.dropLast()
        return encoded
    }
    func decode(from style: String) {
        func getFloat(_ string: String?) -> CGFloat? {
            guard let string = string?.trimmingCharacters(in: .whitespaces), !string.isEmpty else {
                return nil
            }
            return Double(string) != nil ? CGFloat(Double(string)!) : nil
        }
        func getBool(_ string: String?) -> Bool? {
            guard let string = string, !string.isEmpty else {
                return nil
            }
            let trimmedString = string.trimmingCharacters(in: .whitespaces).lowercased()
            if ["true", "yes"].contains(trimmedString) {
                return true
            } else if ["false", "no"].contains(trimmedString) {
                return false
            } else {
                return nil
            }
        }
        func getColor(_ string: String?, inDisplayP3: Bool) -> NSColor? {
            guard let string = string?.trimmingCharacters(in: .whitespaces), !string.isEmpty else {
                return nil
            }
            var r = 0, g = 0, b = 0, a = 0xff
            if (string.count == 10) {
              // 0xffccbbaa
                let regex = try! NSRegularExpression(pattern: "^0x([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$", options: .caseInsensitive)
                let matches = regex.matches(in: string, options: .init(rawValue: 0), range: NSMakeRange(0, string.endIndex.utf16Offset(in: string)))
                if matches.count == 1 {
                    r = Int((string as NSString).substring(with: matches[0].range(at: 4)), radix: 16)!
                    g = Int((string as NSString).substring(with: matches[0].range(at: 3)), radix: 16)!
                    b = Int((string as NSString).substring(with: matches[0].range(at: 2)), radix: 16)!
                    a = Int((string as NSString).substring(with: matches[0].range(at: 1)), radix: 16)!
                } else {
                    return nil
                }
            } else if (string.count == 8) {
              // 0xccbbaa
              let regex = try! NSRegularExpression(pattern: "^0x([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$", options: .caseInsensitive)
              let matches = regex.matches(in: string, options: .init(rawValue: 0), range: NSMakeRange(0, string.endIndex.utf16Offset(in: string)))
              if matches.count == 1 {
                  r = Int((string as NSString).substring(with: matches[0].range(at: 3)), radix: 16)!
                  g = Int((string as NSString).substring(with: matches[0].range(at: 2)), radix: 16)!
                  b = Int((string as NSString).substring(with: matches[0].range(at: 1)), radix: 16)!
              } else {
                  return nil
              }
            }
            if (inDisplayP3) {
                return NSColor(displayP3Red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
            } else {
                return NSColor(srgbRed: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
            }
        }
        let regex = try! NSRegularExpression(pattern: "([a-z_0-9]+)\\s*:[\\s\"]*([^\\s\"#][^\"#]*)[\\s\"#]*(#*.*)$", options: .caseInsensitive)
        var values = Dictionary<String, String>()
        for line in style.split(whereSeparator: \.isNewline) {
            let line = String(line)
            let matches = regex.matches(in: line, options: .init(rawValue: 0), range: NSMakeRange(0, line.endIndex.utf16Offset(in: line)))
            for match in matches {
                values[(line as NSString).substring(with: match.range(at: 1))] = (line as NSString).substring(with: match.range(at: 2))
            }
        }
        let name = values["name"]
        let isDisplayP3 = (values["color_space"] == "display_p3")
        var linear: Bool? = nil
        if let lin = values["candidate_list_layout"] {
            if lin == "linear" {
                linear = true
            } else if lin == "stacked" {
                linear = false
            }
        } else {
            linear = getBool(values["horizontal"])
        }
        var vertical: Bool? = nil
        if let ver = values["text_orientation"] {
            if ver == "vertical" {
                vertical = true
            } else if ver == "horizontal" {
                vertical = false
            }
        } else {
            vertical = getBool(values["vertical"])
        }
        let inlinePreedit = getBool(values["inline_preedit"])
        let translucency = getBool(values["translucency"])
        let mutualExclusive = getBool(values["mutual_exclusive"])
        let cornerRadius = getFloat(values["corner_radius"])
        let surroundingExtraExpansion = getFloat(values["surrounding_extra_expansion"])
        let hilitedCornerRadius = getFloat(values["hilited_corner_radius"])
        let borderWidth = getFloat(values["border_width"])
        let borderHeight = getFloat(values["border_height"])
        let linespace = getFloat(values["line_spacing"])
        let preeditLinespace = getFloat(values["spacing"])
        let baseOffset = getFloat(values["base_offset"])
        let alpha = getFloat(values["alpha"])
        let shadowSize = getFloat(values["shadow_size"])
        
        let fontFace = values["font_face"]
        let fontPoint = getFloat(values["font_point"])
        let labelFontFace = values["label_font_face"]
        let labelFontPoint = getFloat(values["label_font_point"])
        let commentFontFace = values["comment_font_face"]
        let commentFontPoint = getFloat(values["comment_font_point"])
        let fonts = fontFace != nil ? decodeFonts(from: fontFace!, size: fontPoint ?? 15) : self.fonts
        let labelFonts = labelFontFace != nil ? decodeFonts(from: labelFontFace!, size: labelFontPoint ?? (fontPoint ?? 15)) : Array<NSFont>()
        let commentFonts = commentFontFace != nil ? decodeFonts(from: commentFontFace!, size: commentFontPoint ?? (fontPoint ?? 15)) : Array<NSFont>()
        
        let backgroundColor = getColor(values["back_color"], inDisplayP3: isDisplayP3)
        let candidateBackColor = getColor(values["candidate_back_color"], inDisplayP3: isDisplayP3)
        let highlightedStripColor = getColor(values["hilited_candidate_back_color"], inDisplayP3: isDisplayP3)
        let highlightedPreeditColor = getColor(values["hilited_back_color"], inDisplayP3: isDisplayP3)
        let preeditBackgroundColor = getColor(values["preedit_back_color"], inDisplayP3: isDisplayP3)
        let borderColor = getColor(values["border_color"], inDisplayP3: isDisplayP3)
        let textColor = getColor(values["text_color"], inDisplayP3: isDisplayP3)
        let highlightedTextColor = getColor(values["hilited_text_color"], inDisplayP3: isDisplayP3)
        let candidateTextColor = getColor(values["candidate_text_color"], inDisplayP3: isDisplayP3)
        let highlightedCandidateTextColor = getColor(values["hilited_candidate_text_color"], inDisplayP3: isDisplayP3)
        let candidateLabelColor = getColor(values["label_color"], inDisplayP3: isDisplayP3)
        let highlightedCandidateLabelColor = getColor(values["hilited_candidate_label_color"], inDisplayP3: isDisplayP3)
        let commentTextColor = getColor(values["comment_text_color"], inDisplayP3: isDisplayP3)
        let highlightedCommentTextColor = getColor(values["hilited_comment_text_color"], inDisplayP3: isDisplayP3)
        
        self.name = name ?? "customized_color_scheme"
        self.fonts = !fonts.isEmpty ? fonts : [NSFont.userFont(ofSize: 15)!]
        self.labelFonts = labelFonts
        self.commentFonts = commentFonts
        self.linear = linear ?? false
        self.vertical = vertical ?? false
        self.inlinePreedit = inlinePreedit ?? false
        self.translucency = translucency ?? false
        self.mutualExclusive = mutualExclusive ?? false
        self.isDisplayP3 = isDisplayP3
        self.backgroundColor = backgroundColor ?? NSColor.windowBackgroundColor
        self.stripColor = candidateBackColor
        self.candidateTextColor = candidateTextColor ?? NSColor.controlTextColor
        self.highlightedStripColor = highlightedStripColor ?? NSColor.selectedTextBackgroundColor
        self.highlightedCandidateTextColor = highlightedCandidateTextColor ?? NSColor.selectedControlTextColor
        self.preeditBackgroundColor = preeditBackgroundColor
        self.textColor = textColor ?? NSColor.disabledControlTextColor
        self.highlightedPreeditColor = highlightedPreeditColor
        self.highlightedTextColor = highlightedTextColor ?? NSColor.controlTextColor
        self.borderColor = borderColor
        self.commentTextColor = commentTextColor ?? NSColor.disabledControlTextColor
        self.highlightedCommentTextColor = highlightedCommentTextColor
        self.candidateLabelColor = candidateLabelColor
        self.highlightedCandidateLabelColor = highlightedCandidateLabelColor
        self.borderWidth = borderWidth ?? 0
        self.borderHeight = borderHeight ?? 0
        self.surroundingExtraExpansion = surroundingExtraExpansion ?? 0
        self.cornerRadius = cornerRadius ?? 0
        self.hilitedCornerRadius = hilitedCornerRadius ?? 0
        self.linespace = linespace ?? 0
        self.preeditLinespace = preeditLinespace ?? 0
        self.baseOffset = baseOffset ?? 0
        self.alpha = alpha ?? 1
        self.shadowSize = shadowSize ?? 0
    }
}

func blendColor(foregroundColor: NSColor, backgroundColor: NSColor?) -> NSColor {
    let foregroundColor = foregroundColor.usingColorSpace(NSColorSpace.deviceRGB) ?? NSColor.lightGray
    let backgroundColor = backgroundColor?.usingColorSpace(NSColorSpace.deviceRGB) ?? NSColor.lightGray
    func blend(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return (a * 2 + b) / 3
    }
    return NSColor(deviceRed: blend(foregroundColor.redComponent, backgroundColor.redComponent),
                   green: blend(foregroundColor.greenComponent, backgroundColor.greenComponent),
                   blue: blend(foregroundColor.blueComponent, backgroundColor.blueComponent),
                   alpha: blend(foregroundColor.alphaComponent, backgroundColor.alphaComponent))
}

class SquirrelView: NSView {
    var shape: CAShapeLayer = CAShapeLayer()
    private var _layout: SquirrelLayout
    let _textView: NSTextView
    private var _candidateRanges: Array<NSRange> = []
    private var _highlightedIndex: Int = 0
    private var _preeditRange: NSRange = NSMakeRange(NSNotFound, 0)
    private var _highlightedPreeditRange: NSRange = NSMakeRange(NSNotFound, 0)
    private var _separatorWidth: CGFloat = 0
    
    override init(frame frameRect: NSRect) {
        // Use textStorage to store text and manage all text layout and draws
        let textContainer = NSTextContainer(containerSize: NSZeroSize)
        textContainer.lineFragmentPadding = 0.0
        _textView = NSTextView(frame: frameRect)
        _textView.drawsBackground = false
        _textView.isEditable = false
        _textView.isSelectable = false
        _textView.replaceTextContainer(textContainer)
        _textView.layoutManager?.backgroundLayoutEnabled = true
        _layout = SquirrelLayout(new: false)
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Need flipped coordinate system, as required by textStorage
    override var isFlipped: Bool {
        true
    }
    var isDark: Bool {
        self.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
    // Get the rectangle containing entire contents, expensive to calculate
    var contentRect: NSRect {
        self.contentRect(forRange: NSMakeRange(0, _textView.textStorage!.length))
    }
    // Get the rectangle containing the range of text, will first convert to glyph range, expensive to calculate
    func contentRect(forRange range: NSRange) -> NSRect {
        let glyphRange = _textView.layoutManager!.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        var rect = _textView.layoutManager!.boundingRect(forGlyphRange: glyphRange, in: _textView.textContainer!)
        var actualWidth: CGFloat = 0
        _textView.layoutManager!.enumerateLineFragments(forGlyphRange: glyphRange) {
            rect, usedRect, container, usedRange, stop in
            let str = self._textView.textStorage!.attributedSubstring(from: usedRange).string as NSString
            let nonWhiteCharLocation = str.rangeOfCharacter(from: .whitespacesAndNewlines.inverted, options: .backwards)
            if nonWhiteCharLocation.location != NSNotFound {
                let newRange = NSMakeRange(usedRange.location, NSMaxRange(nonWhiteCharLocation))
                let newGlyphRange = self._textView.layoutManager!.glyphRange(forCharacterRange: newRange, actualCharacterRange: nil)
                let lineWidth = self._textView.layoutManager!.boundingRect(forGlyphRange: newGlyphRange, in: self._textView.textContainer!).width
                if actualWidth < lineWidth {
                    actualWidth = lineWidth
                }
            }
        }
        rect.size.width = actualWidth
        return rect
    }
    var layout: SquirrelLayout {
        get {
            _layout
        } set {
            _layout = newValue
        }
    }
    // Will triger - (void)drawRect:(NSRect)dirtyRect
    func drawView(withCandidateRanges candidateRanges: Array<NSRange>, hilitedIndex: Int, preeditRange: NSRange, hilitedPreeditRange: NSRange, separatorWidth: CGFloat) {
        _candidateRanges = candidateRanges
        _highlightedIndex = hilitedIndex
        _preeditRange = preeditRange
        _highlightedPreeditRange = hilitedPreeditRange
        _separatorWidth = separatorWidth
        self.needsDisplay = true
    }
    
    // All draws happen here
    override func draw(_ dirtyRect: NSRect) {
        
        func xyTranslate(points: Array<NSPoint>, direction: NSPoint) -> Array<NSPoint> {
            var newVertex = Array<NSPoint>()
            for point in points {
                newVertex.append(point.applying(CGAffineTransform(translationX: direction.x, y: direction.y)))
            }
            return newVertex
        }
        
        // A tweaked sign function, to winddown corner radius when the size is small
        func sign(_ number: CGFloat) -> CGFloat {
            if number >= 2 {
                return 1
            } else if number <= -2 {
                return -1
            }else {
                return number / 2
            }
        }
        // Bezier cubic curve, which has continuous roundness
        func drawSmoothLines(_ vertex: Array<NSPoint>, straightCorner: Set<Int>, alpha: CGFloat, beta: CGFloat) -> CGPath? {
            guard vertex.count >= 4 else {
                return nil
            }
            let path = CGMutablePath()
            var previousPoint = vertex[vertex.count-1]
            var point = vertex[0]
            var nextPoint: NSPoint
            var control1: NSPoint
            var control2: NSPoint
            var target = previousPoint
            var diff = NSMakePoint(point.x - previousPoint.x, point.y - previousPoint.y)
            if straightCorner.isEmpty || !straightCorner.contains(vertex.count-1) {
                if abs(diff.x) >= abs(diff.y) {
                    target.x += sign(diff.x/beta)*beta
                } else {
                    target.y += sign(diff.y/beta)*beta
                }
            }
            path.move(to: target)
            for i in 0..<vertex.count {
                previousPoint = vertex[(vertex.count+i-1)%vertex.count]
                point = vertex[i]
                nextPoint = vertex[(i+1)%vertex.count]
                target = point
                if straightCorner.contains(i) {
                    path.addLine(to: target)
                } else {
                    control1 = point
                    diff = NSMakePoint(point.x - previousPoint.x, point.y - previousPoint.y)
                    if (abs(diff.x) >= abs(diff.y)) {
                        target.x -= sign(diff.x/beta)*beta
                        control1.x -= sign(diff.x/beta)*alpha
                    } else {
                        target.y -= sign(diff.y/beta)*beta
                        control1.y -= sign(diff.y/beta)*alpha
                    }
                    path.addLine(to: target)
                    target = point
                    control2 = point
                    diff = NSMakePoint(nextPoint.x - point.x, nextPoint.y - point.y)
                    if (abs(diff.x) > abs(diff.y)) {
                        control2.x += sign(diff.x/beta)*alpha
                        target.x += sign(diff.x/beta)*beta
                    } else {
                        control2.y += sign(diff.y/beta)*alpha
                        target.y += sign(diff.y/beta)*beta
                    }
                    path.addCurve(to: target, control1: control1, control2: control2)
                }
            }
            path.closeSubpath()
            return path
        }
        
        func vertex(ofRect rect: NSRect) -> Array<NSPoint> {
            [rect.origin,
            NSMakePoint(rect.origin.x, rect.origin.y+rect.size.height),
            NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height),
            NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y)]
        }
        
        func nearEmpty(_ rect: NSRect) -> Bool {
            return rect.size.height * rect.size.width < 1
        }
        // Calculate 3 boxes containing the text in range. leadingRect and trailingRect are incomplete line rectangle
        // bodyRect is complete lines in the middle
        func multilineRects(forRange charRange: NSRange) -> (NSRect, NSRect, NSRect) {
            let layoutManager = _textView.layoutManager!
            let textContainer = _textView.textContainer!
            let glyphRange = layoutManager.glyphRange(forCharacterRange: charRange, actualCharacterRange: nil)
            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let fullRangeInBoundingRect = layoutManager.glyphRange(forBoundingRect: boundingRect, in: textContainer)
            var leadingRect = NSZeroRect
            var bodyRect = boundingRect
            var trailingRect = NSZeroRect
            if (boundingRect.origin.x <= 1) && (fullRangeInBoundingRect.location < glyphRange.location) {
                leadingRect = layoutManager.boundingRect(
                    forGlyphRange: NSMakeRange(fullRangeInBoundingRect.location, glyphRange.location-fullRangeInBoundingRect.location),
                    in: textContainer)
                if !nearEmpty(leadingRect) {
                    bodyRect.size.height -= leadingRect.size.height
                    bodyRect.origin.y += leadingRect.size.height
                }
                let rightEdge = NSMaxX(leadingRect)
                leadingRect.origin.x = rightEdge
                leadingRect.size.width = bodyRect.origin.x + bodyRect.size.width - rightEdge
            }
            if fullRangeInBoundingRect.location+fullRangeInBoundingRect.length > glyphRange.location+glyphRange.length {
                trailingRect = layoutManager.boundingRect(
                    forGlyphRange: NSMakeRange(glyphRange.location+glyphRange.length,
                                               fullRangeInBoundingRect.location+fullRangeInBoundingRect.length-glyphRange.location-glyphRange.length),
                    in: textContainer)
                if !nearEmpty(trailingRect) {
                    bodyRect.size.height -= trailingRect.size.height
                }
                let leftEdge = NSMinX(trailingRect)
                trailingRect.origin.x = bodyRect.origin.x
                trailingRect.size.width = leftEdge - bodyRect.origin.x
            } else if fullRangeInBoundingRect.location+fullRangeInBoundingRect.length == glyphRange.location+glyphRange.length {
                trailingRect = layoutManager.lineFragmentUsedRect(forGlyphAt: glyphRange.location+glyphRange.length-1, effectiveRange: nil)
                if NSMaxX(trailingRect) >= NSMaxX(boundingRect) - 1 {
                    trailingRect = NSZeroRect
                } else if !nearEmpty(trailingRect) {
                    bodyRect.size.height -= trailingRect.size.height
                }
            }
            let lastLineRect = nearEmpty(trailingRect) ? bodyRect : trailingRect
//            lastLineRect.size.width = textContainer.containerSize.width - lastLineRect.origin.x
            var lastLineRange = layoutManager.glyphRange(forBoundingRect: lastLineRect, in: textContainer)
            var glyphProperty = layoutManager.propertyForGlyph(at: lastLineRange.location+lastLineRange.length-1)
            while (lastLineRange.length>0) && ((glyphProperty == .elastic) || (glyphProperty == .controlCharacter)) {
                lastLineRange.length -= 1
                glyphProperty = layoutManager.propertyForGlyph(at: lastLineRange.location+lastLineRange.length-1)
            }
            if lastLineRange.location+lastLineRange.length == glyphRange.location+glyphRange.length {
                if !nearEmpty(trailingRect) {
                    trailingRect = lastLineRect
                } else {
                    bodyRect = lastLineRect
                }
            }
            let edgeInset = _layout.edgeInset
            leadingRect.origin.x += edgeInset.width
            leadingRect.origin.y += edgeInset.height
            bodyRect.origin.x += edgeInset.width
            bodyRect.origin.y += edgeInset.height
            trailingRect.origin.x += edgeInset.width
            trailingRect.origin.y += edgeInset.height
            
            return (leadingRect, bodyRect, trailingRect)
        }
        // Based on the 3 boxes from multilineRectForRange, calculate the vertex of the polygon containing the text in range
        func multilineVertex(ofLeadingRect leadingRect: NSRect, bodyRect: NSRect, trailingRect: NSRect) -> Array<NSPoint> {
            if nearEmpty(bodyRect) && !nearEmpty(leadingRect) && nearEmpty(trailingRect) {
                return vertex(ofRect: leadingRect)
            } else if nearEmpty(bodyRect) && nearEmpty(leadingRect) && !nearEmpty(trailingRect) {
                return vertex(ofRect: trailingRect)
            } else if nearEmpty(leadingRect) && nearEmpty(trailingRect) && !nearEmpty(bodyRect) {
                return vertex(ofRect: bodyRect)
            } else if nearEmpty(trailingRect) && !nearEmpty(bodyRect) {
                let leadingVertex = vertex(ofRect: leadingRect)
                let bodyVertex = vertex(ofRect: bodyRect)
                return [bodyVertex[0], bodyVertex[1], bodyVertex[2], leadingVertex[3], leadingVertex[0], leadingVertex[1]]
            } else if nearEmpty(leadingRect) && !nearEmpty(bodyRect) {
                let trailingVertex = vertex(ofRect: trailingRect)
                let bodyVertex = vertex(ofRect: bodyRect)
                return [trailingVertex[1], trailingVertex[2], trailingVertex[3], bodyVertex[2], bodyVertex[3], bodyVertex[0]]
            } else if !nearEmpty(leadingRect) && !nearEmpty(trailingRect) && nearEmpty(bodyRect) && (NSMaxX(leadingRect)>NSMinX(trailingRect)) {
                let leadingVertex = vertex(ofRect: leadingRect)
                let trailingVertex = vertex(ofRect: trailingRect)
                return [trailingVertex[0], trailingVertex[1], trailingVertex[2], trailingVertex[3], leadingVertex[2], leadingVertex[3], leadingVertex[0], leadingVertex[1]]
            } else if !nearEmpty(leadingRect) && !nearEmpty(trailingRect) && !nearEmpty(bodyRect) {
                let leadingVertex = vertex(ofRect: leadingRect)
                let bodyVertex = vertex(ofRect: bodyRect)
                let trailingVertex = vertex(ofRect: trailingRect)
                return [trailingVertex[1], trailingVertex[2], trailingVertex[3], bodyVertex[2], leadingVertex[3], leadingVertex[0], leadingVertex[1], bodyVertex[0]]
            } else {
                return Array<NSPoint>()
            }
        }
        // If the point is outside the innerBox, will extend to reach the outerBox
        func expand(vertex: Array<NSPoint>, innerBorder: NSRect, outerBorder: NSRect) -> Array<NSPoint> {
            var newVertex = Array<NSPoint>()
            for i in 0..<vertex.count {
                var point = vertex[i]
                if point.x < innerBorder.origin.x {
                    point.x = outerBorder.origin.x
                } else if point.x > innerBorder.origin.x+innerBorder.size.width {
                    point.x = outerBorder.origin.x+outerBorder.size.width
                }
                if point.y < innerBorder.origin.y {
                    point.y = outerBorder.origin.y
                } else if point.y > innerBorder.origin.y+innerBorder.size.height {
                    point.y = outerBorder.origin.y+outerBorder.size.height
                }
                newVertex.append(point)
            }
            return newVertex
        }
        func direction(diff: CGPoint) -> CGPoint {
          if diff.y == 0 && diff.x > 0 {
            return NSMakePoint(0, 1)
          } else if diff.y == 0 && diff.x < 0 {
            return NSMakePoint(0, -1)
          } else if diff.x == 0 && diff.y > 0 {
            return NSMakePoint(-1, 0)
          } else if diff.x == 0 && diff.y < 0 {
            return NSMakePoint(1, 0)
          } else {
            return NSMakePoint(0, 0)
          }
        }
        // Assumes clockwise iteration
        func enlarge(vertex: Array<NSPoint>, by: Double) -> Array<NSPoint> {
            if by != 0 {
                var previousPoint: NSPoint
                var point: NSPoint
                var nextPoint: NSPoint
                var results = vertex
                var newPoint: NSPoint
                var displacement: NSPoint
                for i in 0..<vertex.count {
                    previousPoint = vertex[(vertex.count+i-1) % vertex.count]
                    point = vertex[i]
                    nextPoint = vertex[(i+1) % vertex.count]
                    newPoint = point
                    displacement = direction(diff: NSMakePoint(point.x - previousPoint.x, point.y - previousPoint.y))
                    newPoint.x += by * displacement.x
                    newPoint.y += by * displacement.y
                    displacement = direction(diff: NSMakePoint(nextPoint.x - point.x, nextPoint.y - point.y))
                    newPoint.x += by * displacement.x
                    newPoint.y += by * displacement.y
                    results[i] = newPoint
                }
                return results
            } else {
                return vertex
            }
        }
        // Add gap between horizontal candidates
        func addGapBetweenHorizontalCandidates(_ rect: NSRect, range: NSRange) -> NSRect {
            var newRect = rect
            if NSMaxRange(range) == _textView.textStorage!.length {
                if !nearEmpty(rect) {
                    newRect.size.width += _separatorWidth
                    newRect.origin.x -= _separatorWidth / 2
                }
            } else if range.location - ((_preeditRange.location == NSNotFound ? 0 : _preeditRange.location) + _preeditRange.length) <= 1 {
                if !nearEmpty(rect) {
                    newRect.size.width += _separatorWidth / 2
                }
            } else {
                if !nearEmpty(rect) {
                    newRect.size.width += _separatorWidth
                    newRect.origin.x -= _separatorWidth / 2
                }
            }
            return newRect
        }
        
        func removeCorner(highlightedPoints: Array<CGPoint>, rightCorners: Set<Int>, containingRect: NSRect) -> Set<Int> {
            if !highlightedPoints.isEmpty && !rightCorners.isEmpty {
                var result = rightCorners
                for cornerIndex in rightCorners {
                    let corner = highlightedPoints[cornerIndex]
                    let dist = min(NSMaxY(containingRect) - corner.y, corner.y - NSMinY(containingRect))
                    if dist < 1e-2 {
                        result.remove(cornerIndex)
                    }
                }
                return result
            } else {
                return rightCorners
            }
        }
        
        func linearMultilineFor(body: NSRect, leading: NSRect, trailing: NSRect) -> (Array<NSPoint>, Array<NSPoint>, Set<Int>, Set<Int>) {
            let highlightedPoints, highlightedPoints2: Array<NSPoint>
            let rightCorners, rightCorners2: Set<Int>
            // Handles the special case where containing boxes are separated
            if (nearEmpty(body) && !nearEmpty(leading) && !nearEmpty(trailing) && NSMaxX(trailing) < NSMinX(leading)) {
                highlightedPoints = vertex(ofRect: leading)
                highlightedPoints2 = vertex(ofRect: trailing)
                rightCorners = [2, 3]
                if highlightedPoints2.count > 0 {
                    rightCorners2 = [0, 1]
                } else {
                    rightCorners2 = []
                }
            } else {
                highlightedPoints = multilineVertex(ofLeadingRect: leading, bodyRect: body, trailingRect: trailing)
                highlightedPoints2 = []
                if (nearEmpty(body) && !nearEmpty(leading) && !nearEmpty(trailing)) {
                    if (NSMaxX(trailing) < NSMaxX(leading) && NSMinX(trailing) < NSMinX(leading)) {
                        rightCorners = [0, 1, 4, 5]
                    } else if (NSMaxX(trailing) >= NSMaxX(leading) && NSMinX(trailing) < NSMinX(leading)) {
                        rightCorners = [0, 1]
                    } else {
                        rightCorners = []
                    }
                } else {
                    rightCorners = []
                }
                rightCorners2 = []
            }
            return (highlightedPoints, highlightedPoints2, rightCorners, rightCorners2)
        }
        
        func drawPath(theme: SquirrelLayout, highlightedRange: NSRange, backgroundRect: NSRect, preeditRect: NSRect, containingRect: NSRect, extraExpansion: Double) -> CGPath? {
            let resultingPath: CGMutablePath?
            
            var currentContainingRect = containingRect
            currentContainingRect.size.width += extraExpansion * 2
            currentContainingRect.size.height += extraExpansion * 2
            currentContainingRect.origin.x -= extraExpansion
            currentContainingRect.origin.y -= extraExpansion
            
            let halfLinespace = theme.linespace / 2
            var innerBox = backgroundRect
            innerBox.size.width -= (theme.edgeInset.width + 1) * 2 - 2 * extraExpansion
            innerBox.origin.x += theme.edgeInset.width + 1 - extraExpansion
            innerBox.size.height += 2 * extraExpansion
            innerBox.origin.y -= extraExpansion
            if _preeditRange.length == 0 {
                innerBox.origin.y += theme.edgeInset.height + 1
                innerBox.size.height -= (theme.edgeInset.height + 1) * 2
            } else {
                innerBox.origin.y += preeditRect.size.height + theme.preeditLinespace / 2 + theme.hilitedCornerRadius / 2 + 1
                innerBox.size.height -= theme.edgeInset.height + preeditRect.size.height + theme.preeditLinespace / 2 + theme.hilitedCornerRadius / 2 + 2
            }
            innerBox.size.height -= halfLinespace
            
            var outerBox = backgroundRect
            outerBox.size.height -= preeditRect.size.height + max(0, theme.hilitedCornerRadius + theme.borderLineWidth) - 2 * extraExpansion
            outerBox.size.width -= max(0, theme.hilitedCornerRadius + theme.borderLineWidth)  - 2 * extraExpansion
            outerBox.origin.x += max(0, (theme.hilitedCornerRadius + theme.borderLineWidth) / 2) - extraExpansion
            outerBox.origin.y += preeditRect.size.height + max(0, theme.hilitedCornerRadius + theme.borderLineWidth) / 2 - extraExpansion
            
            let effectiveRadius = max(0, theme.hilitedCornerRadius + 2 * extraExpansion / theme.hilitedCornerRadius * max(0, theme.cornerRadius - theme.hilitedCornerRadius))
            
            if theme.linear {
                var (leadingRect, bodyRect, trailingRect) = multilineRects(forRange: highlightedRange)
                leadingRect = addGapBetweenHorizontalCandidates(leadingRect, range: highlightedRange)
                bodyRect = addGapBetweenHorizontalCandidates(bodyRect, range: highlightedRange)
                trailingRect = addGapBetweenHorizontalCandidates(trailingRect, range: highlightedRange)
                
                var (highlightedPoints, highlightedPoints2, rightCorners, rightCorners2) = linearMultilineFor(body: bodyRect, leading: leadingRect, trailing: trailingRect)
                
                highlightedPoints = xyTranslate(points: highlightedPoints, direction: NSMakePoint(0, -halfLinespace))
                highlightedPoints2 = xyTranslate(points: highlightedPoints2, direction: NSMakePoint(0, -halfLinespace))
                // Expand the boxes to reach proper border
                highlightedPoints = enlarge(vertex: highlightedPoints, by: extraExpansion)
                highlightedPoints = expand(vertex: highlightedPoints, innerBorder: innerBox, outerBorder: outerBox)
                rightCorners = removeCorner(highlightedPoints: highlightedPoints, rightCorners: rightCorners, containingRect: currentContainingRect)
                resultingPath = drawSmoothLines(highlightedPoints, straightCorner: rightCorners, alpha: 0.3*effectiveRadius, beta: 1.4*effectiveRadius)?.mutableCopy()
                
                if (highlightedPoints2.count > 0) {
                    highlightedPoints2 = enlarge(vertex: highlightedPoints2, by: extraExpansion)
                    highlightedPoints2 = expand(vertex: highlightedPoints2, innerBorder: innerBox, outerBorder: outerBox)
                    rightCorners2 = removeCorner(highlightedPoints: highlightedPoints2, rightCorners: rightCorners2, containingRect: currentContainingRect)
                    let highlightedPath2 = drawSmoothLines(highlightedPoints2, straightCorner: rightCorners2, alpha: 0.3*effectiveRadius, beta: 1.4*effectiveRadius)
                    if let highlightedPath2 = highlightedPath2 {
                        resultingPath?.addPath(highlightedPath2)
                    }
                }
            } else {
                var highlightedRect = self.contentRect(forRange: highlightedRange)
                highlightedRect.size.width = backgroundRect.size.width
                highlightedRect.size.height += theme.linespace
                highlightedRect.origin = NSMakePoint(backgroundRect.origin.x, highlightedRect.origin.y + theme.edgeInset.height - halfLinespace)
                if NSMaxRange(highlightedRange) == _textView.textStorage!.length {
                    highlightedRect.size.height += theme.edgeInset.height - halfLinespace
                }
                if highlightedRange.location - ((_preeditRange.location == NSNotFound ? 0 : _preeditRange.location) + _preeditRange.length) <= 1 {
                    if _preeditRange.length == 0 {
                        highlightedRect.size.height += theme.edgeInset.height - halfLinespace
                        highlightedRect.origin.y -= theme.edgeInset.height - halfLinespace
                    } else {
                        highlightedRect.size.height += theme.hilitedCornerRadius / 2
                        highlightedRect.origin.y -= theme.hilitedCornerRadius / 2
                    }
                }
                
                var highlightedPoints = vertex(ofRect: highlightedRect)
                highlightedPoints = enlarge(vertex: highlightedPoints, by: extraExpansion)
                highlightedPoints = expand(vertex: highlightedPoints, innerBorder: innerBox, outerBorder: outerBox)
                resultingPath = drawSmoothLines(highlightedPoints, straightCorner: Set(), alpha: effectiveRadius*0.3, beta: effectiveRadius*1.4)?.mutableCopy()
            }
            return resultingPath
        }
        
        func shapeFromPath(path: CGPath?) -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.path = path
            layer.fillRule = .evenOdd
            return layer
        }
        
        var backgroundPath: CGPath?
        var preeditPath: CGPath?
        var candidatePaths: CGMutablePath?
        var highlightedPath: CGMutablePath?
        var highlightedPreeditPath: CGMutablePath?
        
        var textOrigin = dirtyRect.origin
        textOrigin.x += _layout.edgeInset.width
        textOrigin.y += _layout.edgeInset.height
        
        let backgroundRect = dirtyRect
        var containingRect = dirtyRect
        containingRect.size.height -= (_layout.hilitedCornerRadius + _layout.borderLineWidth) * 2
        containingRect.size.width -= (_layout.hilitedCornerRadius + _layout.borderLineWidth) * 2
        containingRect.origin.x += _layout.hilitedCornerRadius + _layout.borderLineWidth
        containingRect.origin.y += _layout.hilitedCornerRadius + _layout.borderLineWidth
        
        // Draw preedit Rect
        var preeditRect = NSZeroRect
        if (_preeditRange.length > 0) {
            preeditRect = self.contentRect(forRange: _preeditRange)
            preeditRect.size.width = backgroundRect.size.width
            preeditRect.size.height += _layout.edgeInset.height + _layout.preeditLinespace / 2 + _layout.hilitedCornerRadius / 2
            preeditRect.origin = backgroundRect.origin
            if _candidateRanges.count == 0 {
                preeditRect.size.height += _layout.edgeInset.height - _layout.preeditLinespace / 2 - _layout.hilitedCornerRadius / 2
            }
            if _layout.preeditBackgroundColor != nil {
                preeditPath = drawSmoothLines(vertex(ofRect: preeditRect), straightCorner: Set(), alpha: 0, beta: 0)
            }
        }
        // Draw highlighted Rect
        for i in 0..<_candidateRanges.count {
            let candidateRange = _candidateRanges[i]
            if i == _highlightedIndex {
                if (candidateRange.length > 0 && _layout.highlightedStripColor != nil) {
                    highlightedPath = drawPath(theme: _layout, highlightedRange: candidateRange, backgroundRect: backgroundRect, preeditRect: preeditRect, containingRect: containingRect, extraExpansion: 0)?.mutableCopy()
                }
            } else {
                if (candidateRange.length > 0 && _layout.stripColor != nil) {
                    let candidatePath = drawPath(theme: _layout, highlightedRange: candidateRange, backgroundRect: backgroundRect, preeditRect: preeditRect, containingRect: containingRect, extraExpansion:_layout.surroundingExtraExpansion)
                    if candidatePaths == nil {
                        candidatePaths = CGMutablePath()
                    }
                    if let candidatePath = candidatePath {
                        candidatePaths?.addPath(candidatePath)
                    }
                }
            }
        }
        // Draw highlighted part of preedit text
        if (_highlightedPreeditRange.length > 0) && (_layout.highlightedPreeditColor != nil) {
            var innerBox = preeditRect
            innerBox.size.width -= (_layout.edgeInset.width + 1) * 2
            innerBox.origin.x += _layout.edgeInset.width + 1
            innerBox.origin.y += _layout.edgeInset.height + 1
            if _candidateRanges.count == 0 {
                innerBox.size.height -= (_layout.edgeInset.height + 1) * 2
            } else {
                innerBox.size.height -= _layout.edgeInset.height + _layout.preeditLinespace / 2 + _layout.hilitedCornerRadius / 2 + 2
            }
            var outerBox = preeditRect
            outerBox.size.height -= max(0, _layout.hilitedCornerRadius + _layout.borderLineWidth)
            outerBox.size.width -= max(0, _layout.hilitedCornerRadius + _layout.borderLineWidth)
            outerBox.origin.x += max(0, _layout.hilitedCornerRadius + _layout.borderLineWidth) / 2
            outerBox.origin.y += max(0, _layout.hilitedCornerRadius + _layout.borderLineWidth) / 2
            
            let (leadingRect, bodyRect, trailingRect) = multilineRects(forRange: _highlightedPreeditRange)
            var (highlightedPoints, highlightedPoints2, rightCorners, rightCorners2) = linearMultilineFor(body: bodyRect, leading: leadingRect, trailing: trailingRect)
            
            highlightedPoints = expand(vertex: highlightedPoints, innerBorder: innerBox, outerBorder: outerBox)
            rightCorners = removeCorner(highlightedPoints: highlightedPoints, rightCorners: rightCorners, containingRect: containingRect)
            highlightedPreeditPath = drawSmoothLines(highlightedPoints, straightCorner: rightCorners, alpha: 0.3*_layout.hilitedCornerRadius, beta: 1.4*_layout.hilitedCornerRadius)?.mutableCopy()
            if (highlightedPoints2.count > 0) {
                highlightedPoints2 = expand(vertex: highlightedPoints2, innerBorder: innerBox, outerBorder: outerBox)
                rightCorners2 = removeCorner(highlightedPoints: highlightedPoints2, rightCorners: rightCorners2, containingRect: containingRect)
                let highlightedPreeditPath2 = drawSmoothLines(highlightedPoints2, straightCorner: rightCorners2, alpha: 0.3*_layout.hilitedCornerRadius, beta: 1.4*_layout.hilitedCornerRadius)
                if let highlightedPreeditPath2 = highlightedPreeditPath2 {
                    highlightedPreeditPath?.addPath(highlightedPreeditPath2)
                }
            }
        }
        
        backgroundPath = drawSmoothLines(vertex(ofRect: backgroundRect), straightCorner: Set(), alpha: 0.3*_layout.cornerRadius, beta: 1.4*_layout.cornerRadius)
        shape.path = backgroundPath
        
        self.layer?.sublayers = nil
        let backPath = backgroundPath?.mutableCopy()
        if let path = preeditPath {
            backPath?.addPath(path)
        }
        if _layout.mutualExclusive, let path = highlightedPath {
            backPath?.addPath(path)
        }
        if _layout.mutualExclusive, let path = candidatePaths {
            backPath?.addPath(path)
        }
        let panelLayer = shapeFromPath(path: backPath)
        panelLayer.fillColor = _layout.backgroundColor?.cgColor
        let panelLayerMask = shapeFromPath(path: backgroundPath)
        panelLayer.mask = panelLayerMask
        self.layer?.addSublayer(panelLayer)

        if let color = _layout.preeditBackgroundColor, let path = preeditPath {
            let layer = shapeFromPath(path: path)
            layer.fillColor = color.cgColor
            let maskPath = backgroundPath?.mutableCopy()
            if _layout.mutualExclusive, let hilitedPath = highlightedPreeditPath {
                maskPath?.addPath(hilitedPath)
            }
            let mask = shapeFromPath(path: maskPath)
            layer.mask = mask
            panelLayer.addSublayer(layer)
        }
        if _layout.borderLineWidth > 0, let color = _layout.borderColor {
            let borderLayer = shapeFromPath(path: backgroundPath)
            borderLayer.lineWidth = _layout.borderLineWidth * 2
            borderLayer.strokeColor = color.cgColor
            borderLayer.fillColor = nil
            panelLayer.addSublayer(borderLayer)
        }
        if let color = _layout.highlightedPreeditColor, let path = highlightedPreeditPath {
            let layer = shapeFromPath(path: path)
            layer.fillColor = color.cgColor
            panelLayer.addSublayer(layer)
        }
        if let color = _layout.stripColor, let path = candidatePaths {
            let layer = shapeFromPath(path: path)
            layer.fillColor = color.cgColor
            panelLayer.addSublayer(layer)
        }
        if let color = _layout.highlightedStripColor, let path = highlightedPath {
            let layer = shapeFromPath(path: path)
            layer.fillColor = color.cgColor
            if _layout.shadowSize > 0 {
                let shadowLayer = CAShapeLayer()
                shadowLayer.shadowColor = NSColor.black.cgColor
                shadowLayer.shadowOffset = NSMakeSize(_layout.shadowSize/2, (_layout.vertical ? -1 : 1) * _layout.shadowSize/2)
                shadowLayer.shadowPath = highlightedPath
                shadowLayer.shadowRadius = _layout.shadowSize
                shadowLayer.shadowOpacity = 0.2
                let outerPath = backgroundPath?.mutableCopy()
                outerPath?.addPath(path)
                let shadowLayerMask = shapeFromPath(path: outerPath)
                shadowLayer.mask = shadowLayerMask
                layer.addSublayer(shadowLayer)
            }
            panelLayer.addSublayer(layer)
        }
        _textView.textContainerInset = NSMakeSize(textOrigin.x, textOrigin.y)
    }
}

class SquirrelPanel: NSWindow {
    static let kOffsetHeight: CGFloat = 5
    private var _position: NSRect
    private let _view: SquirrelView
    private let _back: NSVisualEffectView
    private var _preeditRange = NSMakeRange(NSNotFound, 0)
    private var _screenRect = NSZeroRect
    private var _maxHeight: CGFloat = 0
    private var _visible = false
    private var _prefixLabelFormat: String?
    private var _suffixLabelFormat: String?
    private var _preedit = ""
    private var _selRange: NSRange = NSMakeRange(NSNotFound, 0)
    private var _candidates = Array<String>()
    private var _comments = Array<String>()
    private var _labels = Array<String>()
    private var _hilitedIndex: UInt = 0
    private var upperLeft: NSPoint?
    weak var parentView: ViewController?
    
    init(position: NSRect) {
        _position = position
        _view = SquirrelView(frame: position)
        let blurView = NSVisualEffectView()
        blurView.blendingMode = .behindWindow
        blurView.material = .hudWindow
        blurView.state = .active
        blurView.wantsLayer = true
        blurView.layer!.mask = _view.shape
        _back = blurView
        super.init(contentRect: position, styleMask: .borderless, backing: .buffered, defer: true)
        self.alphaValue = 1
        self.hasShadow = true
        self.isOpaque = false
        self.backgroundColor = .clear
        let contentView = NSView()
        self.contentView = contentView
        contentView.addSubview(_back)
        contentView.addSubview(_view)
        contentView.addSubview(_view._textView)
        self.isMovableByWindowBackground = true
    }
    
    var layout: SquirrelLayout {
        get {
            _view.layout
        } set {
            _view.layout = newValue
            upperLeft = self.frame.origin
            upperLeft?.y += self.frame.size.height
            if _visible {
                self.updateAndShow()
            }
        }
    }
    var position: NSRect {
        get {
            _position
        } set {
            _position = newValue
            upperLeft = nil
        }
    }
    override var isVisible: Bool {
        _visible
    }
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers! {
            case "w":
                self.hide()
            default:
                break
            }
        }
    }
    func getCurrentScreen() {
        _screenRect = NSScreen.main!.frame
        let screens = NSScreen.screens
        for i in 0..<screens.count {
            let rect = screens[i].frame
            if NSPointInRect(_position.origin, rect) {
                _screenRect = rect
                break
            }
        }
    }
    func getMaxTextWidth(layout: SquirrelLayout) -> CGFloat {
        let currentFont = layout.attrs[.font] as! NSFont
        let fontScale = currentFont.pointSize / 12
        let textWidthRatio = min(1.0, 1.0 / (layout.vertical ? 4 : 3) + fontScale / 12)
        let maxTextWidth = layout.vertical
            ? NSHeight(_screenRect) * textWidthRatio - layout.edgeInset.height * 2
            : NSWidth(_screenRect) * textWidthRatio - layout.edgeInset.width * 2
        return maxTextWidth
    }
    
    func show() {
        self.getCurrentScreen()
        let textWidth = getMaxTextWidth(layout: self.layout)
        let maxTextHeight = layout.vertical ? _screenRect.size.width - layout.edgeInset.width * 2 : _screenRect.size.height - layout.edgeInset.height * 2
        _view._textView.textContainer!.containerSize = NSMakeSize(textWidth, maxTextHeight)
        var windowRect = NSZeroRect
        // in vertical mode, the width and height are interchanged
        var contentRect = _view.contentRect
        if false && (self.layout.vertical && NSMidY(_position) / NSHeight(_screenRect) < 0.5) ||
                (!self.layout.vertical && NSMinX(_position)+max(contentRect.size.width, _maxHeight)+self.layout.edgeInset.width*2 > NSMaxX(_screenRect)) {
            if contentRect.size.width >= _maxHeight {
                _maxHeight = contentRect.size.width
            } else {
                contentRect.size.width = _maxHeight
                _view._textView.textContainer!.containerSize = NSMakeSize(_maxHeight, maxTextHeight)
            }
        }
        if self.layout.vertical {
            windowRect.size = NSMakeSize(contentRect.size.height + self.layout.edgeInset.height * 2,
                                         contentRect.size.width + self.layout.edgeInset.width * 2)
            windowRect.origin.y = NSMaxY(_position) - NSHeight(windowRect)
            windowRect.origin.x = NSMaxX(_position) + Self.kOffsetHeight
        } else {
            windowRect.size = NSMakeSize(contentRect.size.width + self.layout.edgeInset.width * 2,
                                         contentRect.size.height + self.layout.edgeInset.height * 2)
            windowRect.origin = NSMakePoint(NSMinX(_position),
                                            NSMinY(_position) - Self.kOffsetHeight - NSHeight(windowRect))
        }
        if upperLeft != nil {
            windowRect.origin = NSMakePoint(upperLeft!.x, upperLeft!.y - windowRect.size.height)
        }
        if NSMaxX(windowRect) > NSMaxX(_screenRect) {
            if self.layout.vertical {
                windowRect.origin.x = NSMinX(_position) - windowRect.size.width - Self.kOffsetHeight
            } else {
                windowRect.origin.x = NSMaxX(_screenRect) - NSWidth(windowRect)
            }
        }
        if NSMinX(windowRect) < NSMinX(_screenRect) {
            windowRect.origin.x = NSMinX(_screenRect)
        }
        if NSMinY(windowRect) < NSMinY(_screenRect) {
            if self.layout.vertical {
                windowRect.origin.y = NSMinY(_screenRect)
            } else {
                windowRect.origin.y = NSMaxY(_position) + Self.kOffsetHeight
            }
        }
        if NSMaxY(windowRect) > NSMaxY(_screenRect) {
            windowRect.origin.y = NSMaxY(_screenRect) - NSHeight(windowRect)
        }
        if NSMinY(windowRect) < NSMinY(_screenRect) {
            windowRect.origin.y = NSMinY(_screenRect)
        }
        self.alphaValue = self.layout.alpha
        self.setFrame(windowRect, display: true)
        // rotate the view, the core in vertical mode!
        if self.layout.vertical {
            self.contentView!.boundsRotation = -90
            _view._textView.boundsRotation = 0
            self.contentView?.setBoundsOrigin(NSMakePoint(0, windowRect.size.width))
        } else {
            self.contentView?.boundsRotation = 0
            _view._textView.boundsRotation = 0
            self.contentView?.setBoundsOrigin(NSMakePoint(0, 0))
        }
        _view.frame = _view.superview!.bounds
        _view._textView.frame = _view.superview!.bounds
        if layout.translucency {
            _back.frame = _back.superview!.bounds
            _back.isHidden = false
        } else {
            _back.isHidden = true
        }
        self.invalidateShadow()
        self.orderFront(nil)
        self._visible = true
        // voila
    }
    
    func hide() {
        self.orderOut(nil)
        _maxHeight = 0
        self._visible = false
        parentView?.showPreviewButton.title = NSLocalizedString("Show Preview", comment: "Show Preview")
    }
    
    func setCandidateFormat(_ candidateFormat: NSString) {
      // in the candiate format, everything other than '%@' is considered part of the label
        let candidateRange = candidateFormat.range(of: "%@")
        if candidateRange.location == NSNotFound {
            _prefixLabelFormat = candidateFormat as String
            _suffixLabelFormat = nil
            return
        }
        if candidateRange.location > 0 {
            // everything before '%@' is prefix label
            let prefixLabelRange = NSMakeRange(0, candidateRange.location)
            _prefixLabelFormat = candidateFormat.substring(with: prefixLabelRange)
        } else {
            _prefixLabelFormat = nil
        }
        if NSMaxRange(candidateRange) < candidateFormat.length {
            // everything after '%@' is suffix label
            let suffixLabelRange = NSMakeRange(NSMaxRange(candidateRange),
                                               candidateFormat.length - NSMaxRange(candidateRange))
            _suffixLabelFormat = candidateFormat.substring(with: suffixLabelRange)
        } else {
            // '%@' is at the end, so suffix label does not exist
            _suffixLabelFormat = nil
        }
    }
    
    func setup(input: InputSource) {
        _preedit = input.preedit
        _selRange = input.selRange
        _candidates = input.candidates
        _comments = input.comments
        _labels = input.labels
        _hilitedIndex = input.index
        setCandidateFormat(input.candidateFormat as NSString)
    }
    
    func updateAndShow() {
        
        func fixDefaultFont(text: NSMutableAttributedString) {
            text.fixAttributes(in: NSMakeRange(0, text.length))
            var currentFontRange = NSMakeRange(NSNotFound, 0)
            var i = 0
            while (i < text.length) {
                let charFont: NSFont = text.attribute(.font, at: i, effectiveRange: &currentFontRange) as! NSFont
                if charFont.fontName == "AppleColorEmoji" {
                    let defaultFont = NSFont.systemFont(ofSize: charFont.pointSize)
                    text.addAttribute(.font, value: defaultFont, range: currentFontRange)
                }
                i = currentFontRange.location + currentFontRange.length
            }
        }
        
        func insert(_ separator: String, to text: NSAttributedString) -> NSAttributedString {
            var range = (text.string as NSString).rangeOfComposedCharacterSequence(at: 0)
            let attributedSeparator = NSAttributedString(string: separator, attributes: text.attributes(at: 0, effectiveRange: nil))
            let workingString: NSMutableAttributedString = text.attributedSubstring(from: range).mutableCopy() as! NSMutableAttributedString
            var i = NSMaxRange(range)
            while i < text.length {
                range = (text.string as NSString).rangeOfComposedCharacterSequence(at: i)
                workingString.append(attributedSeparator)
                workingString.append(text.attributedSubstring(from: range))
                i = NSMaxRange(range)
            }
            return workingString
        }
        
        let text = NSMutableAttributedString()
        _preeditRange = NSMakeRange(NSNotFound, 0)
        var highlightedPreeditRange = NSMakeRange(NSNotFound, 0)
        if !_preedit.isEmpty && !self.layout.inlinePreedit {
            let line = NSMutableAttributedString()
            if _selRange.location > 0 {
                line.append(NSAttributedString(string: String(_preedit[..<String.Index(utf16Offset: _selRange.location, in: _preedit)]).precomposedStringWithCanonicalMapping,
                                               attributes: self.layout.preeditAttrs))
            }
            if _selRange.length > 0 {
                let highlightedPreeditStart = line.length
                line.append(NSAttributedString(string: String(_preedit[Range<String.Index>(_selRange, in: _preedit)!]).precomposedStringWithCanonicalMapping,
                attributes: self.layout.preeditHighlightedAttrs))
                highlightedPreeditRange = NSMakeRange(highlightedPreeditStart, line.length - highlightedPreeditStart)
            }
            if Range<String.Index>(_selRange, in: _preedit)!.upperBound < _preedit.endIndex {
                line.append(NSAttributedString(string: String(_preedit[String.Index(utf16Offset: NSMaxRange(_selRange), in: _preedit)...]).precomposedStringWithCanonicalMapping,
                attributes: self.layout.preeditAttrs))
            }
            text.append(line)
            text.addAttribute(.paragraphStyle, value: layout.preeditParagraphStyle, range: NSMakeRange(0, text.length))
            _preeditRange = NSMakeRange(0, text.length)
            
            if _candidates.count > 0 {
                text.append(NSAttributedString(string: "\n", attributes: self.layout.preeditAttrs))
            }
        }
        var candidateRanges = Array<NSRange>()
        var separatorWidth: CGFloat = 0
        self.getCurrentScreen()
        let maxTextWidth = getMaxTextWidth(layout: self.layout)
        // candidates
        for i in 0..<_candidates.count {
            let attrs = (i == _hilitedIndex) ? self.layout.highlightedAttrs : self.layout.attrs
            let labelAttrs = (i == _hilitedIndex) ? self.layout.labelHighlightedAttrs : self.layout.labelAttrs
            let commentAttrs = (i == _hilitedIndex) ? self.layout.commentHighlightedAttrs : self.layout.commentAttrs
            var labelWidth: CGFloat = 0
            
            let line = NSMutableAttributedString()
            if _prefixLabelFormat != nil {
                let labelString: String
                if _labels.count > 1 && i < _labels.count {
                    let format = _prefixLabelFormat!.replacingOccurrences(of: "%c", with: "%@")
                    labelString = String(format: format, _labels[i]).precomposedStringWithCanonicalMapping
                } else if (_labels.count == 1 && i < _labels[0].count) {
                    // custom: A. B. C...
                    let labelChar = _labels[0][String.Index.init(utf16Offset: i, in: _labels[0])]
                    labelString = String(format: _prefixLabelFormat!, String(labelChar)).precomposedStringWithCanonicalMapping
                } else {
                    // default: 1. 2. 3...
                    let format = _prefixLabelFormat!.replacingOccurrences(of: "%c", with: "%lu")
                    labelString = String(format: format, i+1)
                }
                
                line.append(NSAttributedString(string: labelString, attributes: labelAttrs))
                // get the label size for indent
                if !self.layout.linear {
                    let str = line.mutableCopy() as! NSMutableAttributedString
                    if (layout.vertical) {
                        str.addAttribute(.verticalGlyphForm, value: 1, range: NSMakeRange(0, str.length))
                    }
                    labelWidth = str.boundingRect(with: NSZeroSize, options: .usesLineFragmentOrigin).size.width
                }
            }
            
            let candidate = _candidates[i]
            var candidateAttributedString = NSAttributedString(string: candidate.precomposedStringWithCanonicalMapping, attributes: attrs)
            let candidateWidth = candidateAttributedString.boundingRect(with: NSZeroSize, options: .usesLineFragmentOrigin).size.width
            if candidateWidth <= maxTextWidth * 0.2 {
                candidateAttributedString = insert("\u{2060}", to: candidateAttributedString)
            }
            line.append(candidateAttributedString)
            
            if _suffixLabelFormat != nil {
                let labelString: String
                if _labels.count > 1 && i < _labels.count {
                    let format = _suffixLabelFormat!.replacingOccurrences(of: "%c", with: "%@")
                    labelString = String(format: format, _labels[i]).precomposedStringWithCanonicalMapping
                } else if (_labels.count == 1 && i < _labels[0].count) {
                    // custom: A. B. C...
                    let labelChar = _labels[0][String.Index.init(utf16Offset: i, in: _labels[0])]
                    labelString = String(format: _suffixLabelFormat!, String(labelChar)).precomposedStringWithCanonicalMapping
                } else {
                    // default: 1. 2. 3...
                    let format = _suffixLabelFormat!.replacingOccurrences(of: "%c", with: "%lu")
                    labelString = String(format: format, i+1)
                }
                line.append(NSAttributedString(string: labelString.precomposedStringWithCanonicalMapping, attributes: labelAttrs))
            }
            
            if i < _comments.count && !_comments[i].isEmpty {
                let comment = _comments[i]
                var commentAttributedString = NSAttributedString(string: comment.precomposedStringWithCanonicalMapping, attributes: commentAttrs)
                let commentWidth = commentAttributedString.boundingRect(with: NSZeroSize, options: .usesLineFragmentOrigin).size.width
                if commentWidth <= maxTextWidth * 0.2 {
                    commentAttributedString = insert("\u{2060}", to: commentAttributedString)
                }
                let candidateAndLabelWidth = line.boundingRect(with: NSZeroSize, options: .usesLineFragmentOrigin).size.width
                let commentSeparator: String
                if candidateAndLabelWidth + commentWidth <= maxTextWidth * 0.3 {
                    commentSeparator = "\u{00A0}"
                } else {
                    commentSeparator = " "
                }
                line.append(NSAttributedString(string: commentSeparator, attributes: commentAttrs))
                line.append(commentAttributedString)
            }
            
            let separator = NSAttributedString(string: self.layout.linear ? "  " : "\n", attributes: attrs)
            if layout.linear {
                let str = separator.mutableCopy() as! NSMutableAttributedString
                if layout.vertical {
                    str.addAttribute(.verticalGlyphForm, value: 1, range: NSMakeRange(0, str.length))
                }
                separatorWidth = str.boundingRect(with: NSZeroSize).size.width
            }
            if i > 0 {
                text.append(separator)
            }
            func modifiedStyle(baseStyle: NSParagraphStyle) -> NSParagraphStyle {
                let paragraphStyleCandidate = baseStyle.mutableCopy() as! NSMutableParagraphStyle
                if self.layout.linear {
                    paragraphStyleCandidate.lineSpacing = self.layout.linespace
                    
                }
                paragraphStyleCandidate.headIndent = labelWidth
                return paragraphStyleCandidate as NSParagraphStyle
            }
            if i == 0 {
                line.addAttribute(.paragraphStyle, value: modifiedStyle(baseStyle: self.layout.firstParagraphStyle), range: NSMakeRange(0, line.length))
            } else {
                line.addAttribute(.paragraphStyle, value: modifiedStyle(baseStyle: self.layout.paragraphStyle), range: NSMakeRange(0, line.length))
            }
            
            candidateRanges.append(NSMakeRange(text.length, line.length))
            text.append(line)
        }
        
        // Fix font rendering
        fixDefaultFont(text: text)
        
        _view._textView.textStorage!.setAttributedString(text)
        if self.layout.vertical {
            _view._textView.setLayoutOrientation(.vertical)
        } else {
            _view._textView.setLayoutOrientation(.horizontal)
        }
        _view.drawView(withCandidateRanges: candidateRanges, hilitedIndex: Int(_hilitedIndex), preeditRange: _preeditRange, hilitedPreeditRange: highlightedPreeditRange, separatorWidth: separatorWidth)
        self.show()
    }
}
