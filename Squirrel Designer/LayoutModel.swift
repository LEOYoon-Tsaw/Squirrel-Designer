//
//  LayoutModel.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import AppKit

class SquirrelLayout: NSObject {
    var name: String = "customized_color_scheme"
    var backgroundColor: NSColor?
    var highlightedStripColor: NSColor?
    var highlightedPreeditColor: NSColor?
    var preeditBackgroundColor: NSColor?
    var borderColor: NSColor?
    
    var cornerRadius: CGFloat = 0
    var hilitedCornerRadius: CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderHeight: CGFloat = 0
    var linespace: CGFloat = 0
    var preeditLinespace: CGFloat = 0
    var baseOffset: CGFloat = 0
    var alpha: CGFloat = 1
    
    var linear = false
    var vertical = false
    var inlinePreedit = false
    var isDisplayP3 = true
    
    var font: NSFont?
    var labelFont: NSFont?
    var textColor: NSColor?
    var highlightedTextColor: NSColor?
    var candidateTextColor: NSColor?
    var highlightedCandidateTextColor: NSColor?
    var candidateLabelColor: NSColor?
    var highlightedCandidateLabelColor: NSColor?
    var commentTextColor: NSColor?
    var highlightedCommentTextColor: NSColor?
    
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
        [.foregroundColor: commentTextColor!,
         .font: font!,
         .baselineOffset: baseOffset]
    }
    var commentHighlightedAttrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: highlightedCommentTextColor ?? commentTextColor!,
         .font: font!,
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
        [.foregroundColor: candidateLabelColor ?? blendColor(foregroundColor: self.candidateTextColor!, backgroundColor: self.backgroundColor),
         .font: labelFont ?? font!,
         .baselineOffset: baseOffset]
    }
    var labelHighlightedAttrs: [NSAttributedString.Key : Any] {
        [.foregroundColor: highlightedCandidateLabelColor ?? blendColor(foregroundColor: highlightedCandidateTextColor!, backgroundColor: highlightedStripColor),
         .font: labelFont ?? font!,
         .baselineOffset: baseOffset]
    }

    var paragraphStyle: NSParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = linespace / 2
        style.paragraphSpacingBefore = linespace / 2
        return style as NSParagraphStyle
    }
    var preeditParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = preeditLinespace
        return style as NSParagraphStyle
    }
    
    var edgeInset: NSSize {
        if (self.vertical) {
            return NSMakeSize(max(borderHeight, cornerRadius), max(borderWidth, cornerRadius));
        } else {
            return NSMakeSize(max(borderWidth, cornerRadius), max(borderHeight, cornerRadius));
        }
    }
    var borderLineWidth: CGFloat {
        return min(borderHeight, borderWidth)
    }
    var halfLinespace: CGFloat {
        return linespace / 2
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
