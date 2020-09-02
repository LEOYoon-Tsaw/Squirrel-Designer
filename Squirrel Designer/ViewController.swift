//
//  ViewController.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

let layout = SquirrelLayout()
let preview = SquirrelPanel(position: NSZeroRect)

class ViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet weak var fontPicker: NSPopUpButton!
    @IBOutlet weak var fontStylePicker: NSPopUpButton!
    @IBOutlet weak var fontSizePicker: NSTextField!
    @IBOutlet weak var labelFontToggle: NSSwitch!
    @IBOutlet weak var labelFontPicker: NSPopUpButton!
    @IBOutlet weak var labelFontStylePicker: NSPopUpButton!
    @IBOutlet weak var labelFontSizePicker: NSTextField!
    
    @IBOutlet weak var candidateListLayoutSwitch: NSSegmentedControl!
    @IBOutlet weak var textOrientationSwitch: NSSegmentedControl!
    @IBOutlet weak var preeditPositionSwitch: NSSegmentedControl!
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    @IBOutlet weak var candidateTextColorPicker: NSColorWell!
    @IBOutlet weak var hilitedCandidateBackColorPicker: NSColorWell!
    @IBOutlet weak var hilitedCandidateTextColorPicker: NSColorWell!
    @IBOutlet weak var preeditBackColorToggle: NSSwitch!
    @IBOutlet weak var preeditBackColorPicker: NSColorWell!
    @IBOutlet weak var preeditTextColorPicker: NSColorWell!
    @IBOutlet weak var hilitedPreeditBackColorToggle: NSSwitch!
    @IBOutlet weak var hilitedPreeditBackColorPicker: NSColorWell!
    @IBOutlet weak var hilitedPreeditTextColorPicker: NSColorWell!
    @IBOutlet weak var borderColorToggle: NSSwitch!
    @IBOutlet weak var borderColorPicker: NSColorWell!
    @IBOutlet weak var commentTextColorPicker: NSColorWell!
    @IBOutlet weak var hilitedCommentTextColorToggle: NSSwitch!
    @IBOutlet weak var hilitedCommentTextColorPicker: NSColorWell!
    @IBOutlet weak var labelTextColorToggle: NSSwitch!
    @IBOutlet weak var labelTextColorPicker: NSColorWell!
    @IBOutlet weak var hilitedLabelTextColorToggle: NSSwitch!
    @IBOutlet weak var hilitedLabelTextColorPicker: NSColorWell!
    @IBOutlet weak var displayP3Toggle: NSSwitch!
    
    @IBOutlet weak var borderHeightField: NSTextField!
    @IBOutlet weak var borderWidthField: NSTextField!
    @IBOutlet weak var cornerRadiusField: NSTextField!
    @IBOutlet weak var hilitedCornerRadiusField: NSTextField!
    @IBOutlet weak var lineSpacingField: NSTextField!
    @IBOutlet weak var preeditLineSpacingField: NSTextField!
    @IBOutlet weak var baselineOffsetField: NSTextField!
    @IBOutlet weak var windowAlphaField: NSTextField!
    
    @IBOutlet weak var showPreviewButton: NSButton!
    @IBOutlet weak var generateCodeButton: NSButton!
    
    var childWindow: NSWindowController?

    @IBAction func nameChanged(_ sender: Any) {
        layout.name = nameField.stringValue
    }
    @IBAction func preeditBackColorToggled(_ sender: Any) {
        if preeditBackColorToggle.state == .off {
            preeditBackColorPicker.isEnabled = false
            layout.preeditBackgroundColor = nil
        } else {
            preeditBackColorPicker.isEnabled = true
            layout.preeditBackgroundColor = preeditBackColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedPreeditBackColorToggled(_ sender: Any) {
        if hilitedPreeditBackColorToggle.state == .off {
            hilitedPreeditBackColorPicker.isEnabled = false
            layout.highlightedPreeditColor = nil
        } else {
            hilitedPreeditBackColorPicker.isEnabled = true
            layout.highlightedPreeditColor = hilitedPreeditBackColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func borderColorToggled(_ sender: Any) {
        if borderColorToggle.state == .off {
            borderColorPicker.isEnabled = false
            layout.borderColor = nil
        } else {
            borderColorPicker.isEnabled = true
            layout.borderColor = borderColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedCommentTextColorToggled(_ sender: Any) {
        if hilitedCommentTextColorToggle.state == .off {
            hilitedCommentTextColorPicker.isEnabled = false
            layout.highlightedCommentTextColor = nil
        } else {
            hilitedCommentTextColorPicker.isEnabled = true
            layout.highlightedCommentTextColor = hilitedCommentTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func labelTextColorToggled(_ sender: Any) {
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.isEnabled = false
            layout.candidateLabelColor = nil
        } else {
            labelTextColorPicker.isEnabled = true
            layout.candidateLabelColor = labelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedLabelTextColorToggled(_ sender: Any) {
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.isEnabled = false
            layout.highlightedCandidateLabelColor = nil
        } else {
            hilitedLabelTextColorPicker.isEnabled = true
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func labelFontToggled(_ sender: Any) {
        if labelFontToggle.state == .off {
            labelFontPicker.isEnabled = false
            labelFontStylePicker.isEnabled = false
            labelFontSizePicker.isEnabled = false
            layout.labelFont = nil
        } else {
            labelFontPicker.isEnabled = true
            labelFontStylePicker.isEnabled = true
            labelFontSizePicker.isEnabled = true
            layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
        }
        preview.layout = layout
    }

    @IBAction func candidateListLayoutToggled(_ sender: Any) {
        layout.linear = candidateListLayoutSwitch.selectedSegment == 1
        preview.layout = layout
    }
    @IBAction func textOrientationToggled(_ sender: Any) {
        layout.vertical = textOrientationSwitch.selectedSegment == 1
        preview.layout = layout
    }
    @IBAction func preeditPositionToggled(_ sender: Any) {
        layout.inlinePreedit = preeditPositionSwitch.selectedSegment == 1
        preview.layout = layout
    }
    @IBAction func isDisplayP3Toggled(_ sender: Any) {
        layout.isDisplayP3 = displayP3Toggle.state == .on
        preview.layout = layout
    }
    
    @IBAction func backgroundColorChanged(_ sender: Any) {
        layout.backgroundColor = backgroundColorPicker.color
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
            layout.candidateLabelColor = labelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func candidateTextColorChanged(_ sender: Any) {
        layout.candidateTextColor = candidateTextColorPicker.color
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
            layout.candidateLabelColor = labelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedCandidateBackColorChanged(_ sender: Any) {
        layout.highlightedStripColor = hilitedCandidateBackColorPicker.color
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedCandidateTextColorChanged(_ sender: Any) {
        layout.highlightedCandidateTextColor = hilitedCandidateTextColorPicker.color
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func preeditBackColorChanged(_ sender: Any) {
        layout.preeditBackgroundColor = preeditBackColorPicker.color
        preview.layout = layout
    }
    @IBAction func preeditTextColorChanged(_ sender: Any) {
        layout.textColor = preeditTextColorPicker.color
        preview.layout = layout
    }
    @IBAction func hilitedPreeditBackColorChanged(_ sender: Any) {
        layout.highlightedPreeditColor = hilitedPreeditBackColorPicker.color
        preview.layout = layout
    }
    @IBAction func hilitedPreeditTextColorChanged(_ sender: Any) {
        layout.highlightedTextColor = hilitedPreeditTextColorPicker.color
        preview.layout = layout
    }
    @IBAction func borderColorChanged(_ sender: Any) {
        layout.borderColor = borderColorPicker.color
        preview.layout = layout
    }
    @IBAction func commentTextColorChanged(_ sender: Any) {
        layout.commentTextColor = commentTextColorPicker.color
        if hilitedCommentTextColorToggle.state == .off {
            hilitedCommentTextColorPicker.color = commentTextColorPicker.color
            layout.highlightedCommentTextColor = commentTextColorPicker.color
        }
        preview.layout = layout
    }
    @IBAction func hilitedCommentTextColorChanged(_ sender: Any) {
        layout.highlightedCommentTextColor = hilitedCommentTextColorPicker.color
        preview.layout = layout
    }
    @IBAction func labelTextColorChanged(_ sender: Any) {
        layout.candidateLabelColor = labelTextColorPicker.color
        preview.layout = layout
    }
    @IBAction func hilitedLabelTextColorChanged(_ sender: Any) {
        layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        preview.layout = layout
    }
    
    @IBAction func fontFamilyChange(_ sender: Any) {
        populateFontMember(fontStylePicker, inFamily: fontPicker)
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
        preview.layout = layout
    }
    @IBAction func labelFontFamilyChange(_ sender: Any) {
        populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
        preview.layout = layout
    }
    @IBAction func fontStyleChange(_ sender: Any) {
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
        preview.layout = layout
    }
    @IBAction func labelFontStyleChange(_ sender: Any) {
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
        preview.layout = layout
    }
    @IBAction func fontSizeChange(_ sender: Any) {
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
        preview.layout = layout
    }
    @IBAction func labelFontSizeChange(_ sender: Any) {
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
        preview.layout = layout
    }
    
    @IBAction func borderWidthChanged(_ sender: Any) {
        layout.borderWidth = CGFloat(borderWidthField.doubleValue)
        preview.layout = layout
    }
    @IBAction func borderHeightChanged(_ sender: Any) {
        layout.borderHeight = CGFloat(borderHeightField.doubleValue)
        preview.layout = layout
    }
    @IBAction func cornerRadiusChanged(_ sender: Any) {
        layout.cornerRadius = CGFloat(cornerRadiusField.doubleValue)
        preview.layout = layout
    }
    @IBAction func hilitedCornerRadiusChanged(_ sender: Any) {
        layout.hilitedCornerRadius = CGFloat(hilitedCornerRadiusField.doubleValue)
        preview.layout = layout
    }
    @IBAction func lineSpacingChanged(_ sender: Any) {
        layout.linespace = CGFloat(lineSpacingField.doubleValue)
        preview.layout = layout
    }
    @IBAction func preeditLineSpacingChanged(_ sender: Any) {
        layout.preeditLinespace = CGFloat(preeditLineSpacingField.doubleValue)
        preview.layout = layout
    }
    @IBAction func baselineOffsetChanged(_ sender: Any) {
        layout.baseOffset = CGFloat(baselineOffsetField.doubleValue)
        preview.layout = layout
    }
    @IBAction func windowAlphaChanged(_ sender: Any) {
        layout.alpha = CGFloat(windowAlphaField.doubleValue)
        preview.layout = layout
    }
    @IBAction func showPreview(_ sender: Any) {
        preview.position = view.window!.convertToScreen(view.frame)
        if preview.isVisible {
            preview.hide()
            showPreviewButton.title = "Show Preview"
        } else {
            preview.updateAndShow()
            showPreviewButton.title = "Hide Preview"
        }
    }
    @IBAction func generateCode(_ sender: Any) {
        func getCurrentScreen(at position: NSPoint) -> NSRect {
            var screenRect = NSScreen.main!.frame
            let screens = NSScreen.screens
            for i in 0..<screens.count {
                let rect = screens[i].frame
                if NSPointInRect(position, rect) {
                    screenRect = rect
                    break
                }
            }
            return screenRect
        }
        if childWindow == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let codeWindowController = storyboard.instantiateController(withIdentifier: "Code View Window Controller") as! NSWindowController
            if let codeWindow = codeWindowController.window {
                let codeViewController = codeWindow.contentViewController as! CodeViewController
                codeViewController.parentView = self
                var childFrame = codeWindow.convertToScreen(codeViewController.view.frame)
                let selfFrame = view.window!.convertToScreen(view.frame)
                let screenFrame = getCurrentScreen(at: selfFrame.origin)
                if NSMaxX(selfFrame) + childFrame.size.width + 5 > NSMaxX(screenFrame) {
                    childFrame.origin = NSMakePoint(NSMinX(selfFrame) - childFrame.size.width - 5, NSMaxY(selfFrame) - childFrame.size.height)
                } else {
                    childFrame.origin = NSMakePoint(NSMaxX(selfFrame) + 5, NSMaxY(selfFrame) - childFrame.size.height)
                }
                if NSMaxX(childFrame) > NSMaxX(screenFrame) {
                    childFrame.origin.x = NSMaxX(screenFrame) - NSWidth(childFrame)
                }
                if NSMinX(childFrame) < NSMinX(screenFrame) {
                    childFrame.origin.x = NSMinX(screenFrame)
                }
                codeWindow.setFrameOrigin(childFrame.origin)
                childWindow = codeWindowController
                codeWindowController.showWindow(nil)
                generateCodeButton.title = "Hide Code"
            }
        } else {
            childWindow!.close()
            childWindow = nil
            generateCodeButton.title = "Show Code"
        }
    }
    
    func syncFont() {
        if labelFontToggle.state == .off {
            labelFontPicker.selectItem(withTitle: fontPicker.titleOfSelectedItem!)
            populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
            labelFontStylePicker.selectItem(at: fontStylePicker.indexOfSelectedItem)
            labelFontSizePicker.doubleValue = fontSizePicker.doubleValue
            layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
        }
    }
    func readFont(family: NSPopUpButton, style: NSPopUpButton, size: NSTextField) -> NSFont {
        let fontFamily = family.titleOfSelectedItem!
        let fontMembers = NSFontManager.shared.availableMembers(ofFontFamily: fontFamily)!
        let fontMember = fontMembers[style.indexOfSelectedItem]
        let traits = fontMember[3] as! UInt
        let weight = fontMember[2] as! Int
        return NSFontManager.shared.font(withFamily: fontFamily, traits: .init(rawValue: traits), weight: weight, size: CGFloat(size.doubleValue))!
    }
    func scrollToTop() {
        let maxHeight = max(scrollView.bounds.height, contentView.bounds.height)
        contentView.scroll(NSPoint(x: 0, y: maxHeight))
    }
    func populateFontFamilies(_ picker: NSPopUpButton) {
        picker.removeAllItems()
        picker.addItems(withTitles: NSFontManager.shared.availableFontFamilies)
        picker.selectItem(withTitle: NSFont.userFont(ofSize: 15)!.familyName!)
    }
    func clearFontMember(_ picker: NSPopUpButton) {
        picker.removeAllItems()
    }
    func populateFontMember(_ picker: NSPopUpButton, inFamily familyPicker: NSPopUpButton) {
        picker.removeAllItems()
        if let family = familyPicker.titleOfSelectedItem {
            let members = NSFontManager.shared.availableMembers(ofFontFamily: family)
            for member in members ?? [[Any]]() {
                if let fontType = member[1] as? String {
                    picker.addItem(withTitle: fontType)
                }
            }
        }
    }
    func updateUI() {
        nameField.stringValue = layout.name
        fontPicker.selectItem(withTitle: layout.font!.familyName!)
        populateFontMember(fontStylePicker, inFamily: fontPicker)
        let members = NSFontManager.shared.availableMembers(ofFontFamily: layout.font!.familyName!)
        if let traits = layout.font?.fontName.split(separator: "-").last {
            for i in 0..<(members?.count ?? 0) {
                if (members![i][1] as? String) == String(traits) {
                    fontStylePicker.selectItem(at: i)
                    break
                }
            }
        } else {
            fontStylePicker.selectItem(at: 0)
        }
        fontSizePicker.stringValue = "\(layout.font!.pointSize)"
        if layout.labelFont != nil {
            labelFontPicker.selectItem(withTitle: layout.labelFont!.familyName!)
            populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
            let members = NSFontManager.shared.availableMembers(ofFontFamily: layout.labelFont!.familyName!)
            if let traits = layout.labelFont?.fontName.split(separator: "-").last {
                for i in 0..<(members?.count ?? 0) {
                    if (members![i][1] as? String) == String(traits) {
                        labelFontStylePicker.selectItem(at: i)
                        break
                    }
                }
            } else {
                labelFontStylePicker.selectItem(at: 0)
            }
            labelFontSizePicker.stringValue = "\(layout.labelFont!.pointSize)"
        } else {
            syncFont()
        }
        candidateListLayoutSwitch.selectSegment(withTag: layout.linear ? 1 : 0)
        textOrientationSwitch.selectSegment(withTag: layout.vertical ? 1 : 0)
        preeditPositionSwitch.selectSegment(withTag: layout.inlinePreedit ? 1 : 0)
        displayP3Toggle.state = layout.isDisplayP3 ? .on : .off
        backgroundColorPicker.color = layout.backgroundColor!
        candidateTextColorPicker.color = layout.candidateTextColor!
        hilitedCandidateBackColorPicker.color = layout.highlightedStripColor!
        hilitedCandidateTextColorPicker.color = layout.highlightedCandidateTextColor!
        preeditBackColorToggle.state = layout.preeditBackgroundColor == nil ? .off : .on
        if let preeditBackgroundColor = layout.preeditBackgroundColor {
            preeditBackColorPicker.color = preeditBackgroundColor
        }
        preeditTextColorPicker.color = layout.textColor!
        hilitedPreeditBackColorToggle.state = layout.highlightedPreeditColor == nil ? .off : .on
        if let highlightedPreeditColor = layout.highlightedPreeditColor {
            hilitedPreeditBackColorPicker.color = highlightedPreeditColor
        }
        hilitedPreeditTextColorPicker.color = layout.highlightedTextColor!
        borderColorToggle.state = layout.borderColor == nil ? .off : .on
        if let borderColor = layout.borderColor {
            borderColorPicker.color = borderColor
        }
        commentTextColorPicker.color = layout.commentTextColor!
        hilitedCommentTextColorToggle.state = layout.highlightedCommentTextColor == nil ? .off : .on
        if let highlightedCommentTextColor = layout.highlightedCommentTextColor {
            hilitedCommentTextColorPicker.color = highlightedCommentTextColor
        }
        labelTextColorToggle.state = layout.candidateLabelColor == nil ? .off : .on
        if let candidateLabelColor = layout.candidateLabelColor {
            labelTextColorPicker.color = candidateLabelColor
        }
        hilitedLabelTextColorToggle.state = layout.highlightedCandidateLabelColor == nil ? .off : .on
        if let highlightedCandidateLabelColor = layout.highlightedCandidateLabelColor {
            hilitedLabelTextColorPicker.color = highlightedCandidateLabelColor
        }
        
        if hilitedCommentTextColorToggle.state == .off {
            hilitedCommentTextColorPicker.color = commentTextColorPicker.color
            layout.highlightedCommentTextColor = commentTextColorPicker.color
        }
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
            layout.candidateLabelColor = labelTextColorPicker.color
        }
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
        
        borderHeightField.stringValue = "\(layout.borderHeight)"
        borderWidthField.stringValue = "\(layout.borderWidth)"
        cornerRadiusField.stringValue = "\(layout.cornerRadius)"
        hilitedCornerRadiusField.stringValue = "\(layout.hilitedCornerRadius)"
        lineSpacingField.stringValue = "\(layout.linespace)"
        preeditLineSpacingField.stringValue = "\(layout.preeditLinespace)"
        baselineOffsetField.stringValue = "\(layout.baseOffset)"
        windowAlphaField.stringValue = "\(layout.alpha)"
    }
    func codeViewDidDispear() {
        generateCodeButton.title = "Show Code"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollToTop()
        populateFontFamilies(fontPicker)
        populateFontMember(fontStylePicker, inFamily: fontPicker)
        populateFontFamilies(labelFontPicker)
        populateFontMember(labelFontStylePicker, inFamily: fontPicker)
        labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
        hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
        
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        layout.isDisplayP3 = displayP3Toggle.state == .on
        layout.backgroundColor = backgroundColorPicker.color
        layout.candidateTextColor = candidateTextColorPicker.color
        layout.highlightedStripColor = hilitedCandidateBackColorPicker.color
        layout.highlightedCandidateTextColor = hilitedCandidateTextColorPicker.color
        layout.textColor = preeditTextColorPicker.color
        layout.highlightedTextColor = hilitedPreeditTextColorPicker.color
        layout.commentTextColor = commentTextColorPicker.color
        
        nameField.stringValue = layout.name
        borderWidthField.doubleValue = Double(layout.borderWidth)
        borderHeightField.doubleValue = Double(layout.borderHeight)
        cornerRadiusField.doubleValue = Double(layout.cornerRadius)
        hilitedCornerRadiusField.doubleValue = Double(layout.hilitedCornerRadius)
        lineSpacingField.doubleValue = Double(layout.linespace)
        preeditLineSpacingField.doubleValue = Double(layout.preeditLinespace)
        baselineOffsetField.doubleValue = Double(layout.baseOffset)
        windowAlphaField.doubleValue = Double(layout.alpha)
        
        candidateListLayoutSwitch.selectSegment(withTag: layout.linear ? 1 : 0)
        textOrientationSwitch.selectSegment(withTag: layout.vertical ? 1 : 0)
        preeditPositionSwitch.selectSegment(withTag: layout.inlinePreedit ? 1 : 0)
        displayP3Toggle.state = layout.isDisplayP3 ? .on : .off
        
        preview.layout = layout
        preview.setup(preedit: preedit, selRange: selRange, candidates: candidates, comments: comments, labels: labels, hilited: index, candidateFormat: "%c. %@")
        NSColorPanel.shared.showsAlpha = true
        NSColorPanel.shared.mode = .RGB
    }
    override func viewDidDisappear() {
        NSColorPanel.shared.showsAlpha = false
        NSColorPanel.shared.mode = .wheel
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

