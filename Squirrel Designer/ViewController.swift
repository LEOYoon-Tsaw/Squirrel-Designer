//
//  ViewController.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

let layout = SquirrelLayout()

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
    }
    @IBAction func hilitedPreeditBackColorToggled(_ sender: Any) {
        if hilitedPreeditBackColorToggle.state == .off {
            hilitedPreeditBackColorPicker.isEnabled = false
            layout.highlightedPreeditColor = nil
        } else {
            hilitedPreeditBackColorPicker.isEnabled = true
            layout.highlightedPreeditColor = hilitedPreeditBackColorPicker.color
        }
    }
    @IBAction func borderColorToggled(_ sender: Any) {
        if borderColorToggle.state == .off {
            borderColorPicker.isEnabled = false
            layout.borderColor = nil
        } else {
            borderColorPicker.isEnabled = true
            layout.borderColor = borderColorPicker.color
        }
    }
    @IBAction func hilitedCommentTextColorToggled(_ sender: Any) {
        if hilitedCommentTextColorToggle.state == .off {
            hilitedCommentTextColorPicker.isEnabled = false
            layout.highlightedCommentTextColor = nil
        } else {
            hilitedCommentTextColorPicker.isEnabled = true
            layout.highlightedCommentTextColor = hilitedCommentTextColorPicker.color
        }
    }
    @IBAction func labelTextColorToggled(_ sender: Any) {
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.isEnabled = false
            layout.candidateLabelColor = nil
        } else {
            labelTextColorPicker.isEnabled = true
            layout.candidateLabelColor = labelTextColorPicker.color
        }
    }
    @IBAction func hilitedLabelTextColorToggled(_ sender: Any) {
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.isEnabled = false
            layout.highlightedCandidateLabelColor = nil
        } else {
            hilitedLabelTextColorPicker.isEnabled = true
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
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
    }

    @IBAction func candidateListLayoutToggled(_ sender: Any) {
        layout.linear = candidateListLayoutSwitch.selectedSegment == 1
    }
    @IBAction func textOrientationToggled(_ sender: Any) {
        layout.vertical = textOrientationSwitch.selectedSegment == 1
    }
    @IBAction func preeditPositionToggled(_ sender: Any) {
        layout.inlinePreedit = preeditPositionSwitch.selectedSegment == 1
    }
    @IBAction func isDisplayP3Toggled(_ sender: Any) {
        layout.isDisplayP3 = displayP3Toggle.state == .on
    }
    
    @IBAction func backgroundColorChanged(_ sender: Any) {
        layout.backgroundColor = backgroundColorPicker.color
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
            layout.candidateLabelColor = labelTextColorPicker.color
        }
    }
    @IBAction func candidateTextColorChanged(_ sender: Any) {
        layout.candidateTextColor = candidateTextColorPicker.color
        if labelTextColorToggle.state == .off {
            labelTextColorPicker.color = blendColor(foregroundColor: candidateTextColorPicker.color, backgroundColor: backgroundColorPicker.color)
            layout.candidateLabelColor = labelTextColorPicker.color
        }
    }
    @IBAction func hilitedCandidateBackColorChanged(_ sender: Any) {
        layout.highlightedStripColor = hilitedCandidateBackColorPicker.color
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
    }
    @IBAction func hilitedCandidateTextColorChanged(_ sender: Any) {
        layout.highlightedCandidateTextColor = hilitedCandidateTextColorPicker.color
        if hilitedLabelTextColorToggle.state == .off {
            hilitedLabelTextColorPicker.color = blendColor(foregroundColor: hilitedCandidateTextColorPicker.color, backgroundColor:         hilitedCandidateBackColorPicker.color)
            layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
        }
    }
    @IBAction func preeditBackColorChanged(_ sender: Any) {
        layout.preeditBackgroundColor = preeditBackColorPicker.color
    }
    @IBAction func preeditTextColorChanged(_ sender: Any) {
        layout.textColor = preeditTextColorPicker.color
    }
    @IBAction func hilitedPreeditBackColorChanged(_ sender: Any) {
        layout.highlightedPreeditColor = hilitedPreeditBackColorPicker.color
    }
    @IBAction func hilitedPreeditTextColorChanged(_ sender: Any) {
        layout.highlightedTextColor = hilitedPreeditTextColorPicker.color
    }
    @IBAction func borderColorChanged(_ sender: Any) {
        layout.borderColor = borderColorPicker.color
    }
    @IBAction func commentTextColorChanged(_ sender: Any) {
        layout.commentTextColor = commentTextColorPicker.color
        if hilitedCommentTextColorToggle.state == .off {
            hilitedCommentTextColorPicker.color = commentTextColorPicker.color
            layout.highlightedCommentTextColor = commentTextColorPicker.color
        }
    }
    @IBAction func hilitedCommentTextColorChanged(_ sender: Any) {
        layout.highlightedCommentTextColor = hilitedCommentTextColorPicker.color
    }
    @IBAction func labelTextColorChanged(_ sender: Any) {
        layout.candidateLabelColor = labelTextColorPicker.color
    }
    @IBAction func hilitedLabelTextColorChanged(_ sender: Any) {
        layout.highlightedCandidateLabelColor = hilitedLabelTextColorPicker.color
    }
    
    @IBAction func fontFamilyChange(_ sender: Any) {
        populateFontMember(fontStylePicker, inFamily: fontPicker)
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
    }
    @IBAction func labelFontFamilyChange(_ sender: Any) {
        populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
    }
    @IBAction func fontStyleChange(_ sender: Any) {
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
    }
    @IBAction func labelFontStyleChange(_ sender: Any) {
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
    }
    @IBAction func fontSizeChange(_ sender: Any) {
        layout.font = readFont(family: fontPicker, style: fontStylePicker, size: fontSizePicker)
        syncFont()
    }
    @IBAction func labelFontSizeChange(_ sender: Any) {
        layout.labelFont = readFont(family: labelFontPicker, style: labelFontStylePicker, size: labelFontSizePicker)
    }
    
    @IBAction func borderWidthChanged(_ sender: Any) {
        layout.borderWidth = CGFloat(borderWidthField.doubleValue)
    }
    @IBAction func borderHeightChanged(_ sender: Any) {
        layout.borderHeight = CGFloat(borderHeightField.doubleValue)
    }
    @IBAction func cornerRadiusChanged(_ sender: Any) {
        layout.cornerRadius = CGFloat(cornerRadiusField.doubleValue)
    }
    @IBAction func hilitedCornerRadiusChanged(_ sender: Any) {
        layout.hilitedCornerRadius = CGFloat(hilitedCornerRadiusField.doubleValue)
    }
    @IBAction func lineSpacingChanged(_ sender: Any) {
        layout.linespace = CGFloat(lineSpacingField.doubleValue)
    }
    @IBAction func preeditLineSpacingChanged(_ sender: Any) {
        layout.preeditLinespace = CGFloat(preeditLineSpacingField.doubleValue)
    }
    @IBAction func baselineOffsetChanged(_ sender: Any) {
        layout.baseOffset = CGFloat(baselineOffsetField.doubleValue)
    }
    @IBAction func windowAlphaChanged(_ sender: Any) {
        layout.alpha = CGFloat(windowAlphaField.doubleValue)
    }
    @IBAction func showPreview(_ sender: Any) {
        // Show Preview Panel
    }
    @IBAction func generateCode(_ sender: Any) {
        // Generate Code Here
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
        picker.selectItem(withTitle: NSFont.userFont(ofSize: 12)!.familyName!)
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

