//
//  ViewController.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import CoreData
import Cocoa

var layout = SquirrelLayout(new: false)
var inputSource = InputSource(new: false)
let preview = SquirrelPanel(position: NSZeroRect)
var mainWindowFrame: NSRect?

class FontPopUpButton: NSPopUpButton {
    weak var fontTraits: NSPopUpButton?
}

class FontDeleteButton: NSButton {
    weak var residenceRow: NSGridRow?
}

class VerticallyCenteredTextFieldCell: NSTextFieldCell {

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleFrame = super.titleRect(forBounds: rect)
        let textRect = self.attributedStringValue.boundingRect(with: titleFrame.size, options: .usesLineFragmentOrigin)
        if textRect.size.height < titleFrame.size.height {
            titleFrame.origin.y = rect.origin.y + (rect.size.height - textRect.size.height) / 2.0
            titleFrame.size.height = textRect.size.height
        }
        return titleFrame
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let titleRect = self.titleRect(forBounds: cellFrame)
        self.attributedStringValue.draw(in: titleRect)
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var fontPickerGrid: NSGridView!
    @IBOutlet weak var labelFontPickerGrid: NSGridView!
    @IBOutlet weak var commentFontPickerGrid: NSGridView!
    
    @IBOutlet weak var fontPicker: NSPopUpButton!
    @IBOutlet weak var fontStylePicker: NSPopUpButton!
    @IBOutlet weak var fontSizePicker: NSTextField!
    @IBOutlet weak var labelFontToggle: NSSwitch!
    @IBOutlet weak var labelFontUIString: NSTextField!
    @IBOutlet weak var labelFontPicker: NSPopUpButton!
    @IBOutlet weak var labelFontStylePicker: NSPopUpButton!
    @IBOutlet weak var labelFontSizeUIString: NSTextField!
    @IBOutlet weak var labelFontSizePicker: NSTextField!
    @IBOutlet weak var commentFontToggle: NSSwitch!
    @IBOutlet weak var commentFontUIString: NSTextField!
    @IBOutlet weak var commentFontPicker: NSPopUpButton!
    @IBOutlet weak var commentFontStylePicker: NSPopUpButton!
    @IBOutlet weak var commentFontSizeUIString: NSTextField!
    @IBOutlet weak var commentFontSizePicker: NSTextField!
    
    @IBOutlet weak var candidateListLayoutSwitch: NSSegmentedControl!
    @IBOutlet weak var textOrientationSwitch: NSSegmentedControl!
    @IBOutlet weak var preeditPositionSwitch: NSSegmentedControl!
    @IBOutlet weak var translucencySwitch: NSSegmentedControl!
    @IBOutlet weak var MutualExclusiveSwitch: NSSegmentedControl!
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    @IBOutlet weak var candidateTextColorPicker: NSColorWell!
    @IBOutlet weak var hilitedCandidateBackColorPicker: NSColorWell!
    @IBOutlet weak var candidateBackColorToggle: NSSwitch!
    @IBOutlet weak var candidateBackColorPicker: NSColorWell!
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
    @IBOutlet weak var colorSpacePicker: NSPopUpButton!
    
    @IBOutlet weak var borderHeightField: NSTextField!
    @IBOutlet weak var borderWidthField: NSTextField!
    @IBOutlet weak var cornerRadiusField: NSTextField!
    @IBOutlet weak var hilitedCornerRadiusField: NSTextField!
    @IBOutlet weak var lineSpacingField: NSTextField!
    @IBOutlet weak var preeditLineSpacingField: NSTextField!
    @IBOutlet weak var baselineOffsetField: NSTextField!
    @IBOutlet weak var extraExpansionField: NSTextField!
    @IBOutlet weak var windowAlphaField: NSTextField!
    @IBOutlet weak var shadowSizeField: NSTextField!
    
    @IBOutlet weak var showPreviewButton: NSButton!
    @IBOutlet weak var generateCodeButton: NSButton!
    
    var childWindow: NSWindowController?
    static weak var currentInstance: ViewController?
    
    func resize(_ view: NSView?, width: CGFloat?, height: CGFloat?) {
        if var frame = view?.frame {
            if let width = width {
                frame.size.width = width
            }
            if let height = height {
                frame.size.height = height
            }
            view?.frame = frame
        }
    }
    func shift(_ view: NSView?, x: CGFloat?, y: CGFloat?) {
        if var frame = view?.frame {
            if let x = x {
                frame.origin.x += x
            }
            if let y = y {
                frame.origin.y += y
            }
            view?.frame = frame
        }
    }
    func shiftBellow(_ currentY: CGFloat, by dy: CGFloat, in parentView: NSView) {
        for subview in parentView.subviews {
            if let subview = (subview as? NSGridView) {
                if NSMinY(parentView.convert(subview.frame, to: parentView)) > currentY {
                    shift(subview, x: nil, y: -dy)
                }
            } else {
                if NSMinY(parentView.convert(subview.frame, to: parentView)) < currentY - 5 {
                    shift(subview, x: nil, y: dy)
                }
            }
        }
    }
    func addRow(in grid: NSGridView) {
        let rowHeight = grid.rowSpacing + grid.row(at: 0).height
        let columnWidth = grid.column(at: 0).width
        let picker = FontPopUpButton()
        resize(picker, width: columnWidth, height: nil)
        populateFontFamilies(picker)
        let stylePicker = NSPopUpButton()
        resize(stylePicker, width: columnWidth, height: nil)
        populateFontMember(stylePicker, inFamily: picker)
        stylePicker.action = #selector(ViewController.fontStyleChanged(sender:))
        picker.fontTraits = stylePicker
        picker.action = #selector(ViewController.fontFamilyChanged(sender:))
        let deleteButton = FontDeleteButton()
        deleteButton.title = ""
        deleteButton.setButtonType(.switch)
        deleteButton.bezelStyle = .circular
        deleteButton.isBordered = true
        deleteButton.image = NSImage(named: NSImage.removeTemplateName)
        deleteButton.imagePosition = .imageOverlaps
        resize(deleteButton, width: grid.row(at: 0).height, height: grid.row(at: 0).height)
        let currentY = NSMinY(contentView.convert(grid.frame, to: contentView))
        shiftBellow(currentY, by: -rowHeight, in: contentView)
        grid.addRow(with: [picker, stylePicker, deleteButton])
        shift(grid, x: 0, y: 1)
        deleteButton.residenceRow = grid.row(at: grid.numberOfRows-1)
        deleteButton.action = #selector(ViewController.deleteFontRow(sender:))
        resize(contentView, width: nil, height: contentView.frame.height + rowHeight)
        let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
        contentView.scroll(NSPoint(x: 0, y: viewPoint.y + rowHeight))
    }
    func deleteRow(_ row: NSGridRow?, in grid: NSGridView?) {
        guard let grid = grid else { return }
        let rowHeight = grid.rowSpacing + grid.row(at: 0).height
        if let row = row {
            row.isHidden = true
            let rowIndex = grid.index(of: row)
            grid.removeRow(at: rowIndex)
            shift(grid, x: 0, y: -1)
            let currentY = NSMinY(contentView.convert(grid.frame, to: contentView))
            shiftBellow(currentY, by: rowHeight, in: contentView)
            let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
            resize(contentView, width: nil, height: contentView.frame.height - rowHeight)
            contentView.scroll(NSPoint(x: 0, y: viewPoint.y - rowHeight))
        }
    }
    func updateFonts(in grid: NSGridView, size: NSTextField, to: WritableKeyPath<SquirrelLayout, Array<NSFont>>) {
        var fonts = Array<NSFont>()
        var existingFonts = Set<String>()
        for i in 0..<grid.numberOfRows {
            let row = grid.row(at: i)
            if let fontFamilyPicker = row.cell(at: 0).contentView as? NSPopUpButton,
               let fontTraitsPicker = row.cell(at: 1).contentView as? NSPopUpButton {
                if let font = readFont(family: fontFamilyPicker, style: fontTraitsPicker, size: size) {
                    if !existingFonts.contains(font.familyName!) {
                        fonts.append(font)
                        existingFonts.insert(font.familyName!)
                    }
                }
            }
        }
        if fonts.count == 0 {
            fonts = [NSFont.systemFont(ofSize: NSFont.systemFontSize)]
        }
        layout[keyPath: to] = fonts
    }
    @IBAction func fontPickerGridAddRow(_ sender: Any) {
        addRow(in: fontPickerGrid)
        syncFonts()
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        preview.layout = layout
    }
    @IBAction func labelFontPickerGridAddRow(_ sender: Any) {
        addRow(in: labelFontPickerGrid)
        updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        preview.layout = layout
    }
    @IBAction func commentFontPickerGridAddRow(_ sender: Any) {
        addRow(in: commentFontPickerGrid)
        updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        preview.layout = layout
    }
    @objc func fontFamilyChanged(sender: FontPopUpButton) {
        if let traits = sender.fontTraits {
            populateFontMember(traits, inFamily: sender)
            syncFonts()
        }
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        if labelFontToggle.state == .on {
            updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        }
        if commentFontToggle.state == .on {
            updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        }
        preview.layout = layout
    }
    @objc func fontStyleChanged(sender: NSPopUpButton) {
        syncFonts()
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        if labelFontToggle.state == .on {
            updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        }
        if commentFontToggle.state == .on {
            updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        }
        preview.layout = layout
    }
    @objc func deleteFontRow(sender: FontDeleteButton) {
        deleteRow(sender.residenceRow, in: sender.residenceRow?.gridView)
        syncFonts()
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        if labelFontToggle.state == .on {
            updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        }
        if commentFontToggle.state == .on {
            updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        }
        preview.layout = layout
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        layout.name = nameField.stringValue
    }
    @IBAction func candidateBackColorToggled(_ sender: Any) {
        if candidateBackColorToggle.state == .off {
            candidateBackColorPicker.isEnabled = false
            layout.stripColor = nil
        } else {
            candidateBackColorPicker.isEnabled = true
            layout.stripColor = candidateBackColorPicker.color
        }
        preview.layout = layout
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
            for subview in labelFontPickerGrid.subviews {
                if let button = subview as? NSButton {
                    button.isEnabled = false
                }
            }
            labelFontSizePicker.isEnabled = false
            layout.labelFonts = Array<NSFont>()
        } else {
            for subview in labelFontPickerGrid.subviews {
                if let button = subview as? NSButton {
                    button.isEnabled = true
                }
            }
            labelFontSizePicker.isEnabled = true
            updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        }
        preview.layout = layout
    }
    @IBAction func commentFontToggled(_ sender: Any) {
        if commentFontToggle.state == .off {
            for subview in commentFontPickerGrid.subviews {
                if let button = subview as? NSButton {
                    button.isEnabled = false
                }
            }
            commentFontSizePicker.isEnabled = false
            layout.commentFonts = Array<NSFont>()
        } else {
            for subview in commentFontPickerGrid.subviews {
                if let button = subview as? NSButton {
                    button.isEnabled = true
                }
            }
            commentFontSizePicker.isEnabled = true
            updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
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
    @IBAction func translucencyToggled(_ sender: Any) {
        layout.translucency = translucencySwitch.selectedSegment == 1
        preview.layout = layout
    }
    @IBAction func mutualExclusiveToggled(_ sender: Any) {
        layout.mutualExclusive = MutualExclusiveSwitch.selectedSegment == 1
        preview.layout = layout
    }
    @IBAction func colorSpaceChanged(_ sender: Any) {
        layout.isDisplayP3 = colorSpacePicker.selectedItem?.title == "Display P3"
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
    @IBAction func candidateBackColorChanged(_ sender: Any) {
        layout.stripColor = candidateBackColorPicker.color
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
        syncFonts()
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        preview.layout = layout
    }
    @IBAction func labelFontFamilyChange(_ sender: Any) {
        populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
        updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        preview.layout = layout
    }
    @IBAction func commentFontFamilyChange(_ sender: Any) {
        populateFontMember(commentFontStylePicker, inFamily: commentFontPicker)
        updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        preview.layout = layout
    }
    @IBAction func fontStyleChange(_ sender: Any) {
        syncFonts()
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        preview.layout = layout
    }
    @IBAction func labelFontStyleChange(_ sender: Any) {
        updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        preview.layout = layout
    }
    @IBAction func commentFontStyleChange(_ sender: Any) {
        updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
        preview.layout = layout
    }
    @IBAction func fontSizeChange(_ sender: Any) {
        updateFonts(in: fontPickerGrid, size: fontSizePicker, to: \SquirrelLayout.fonts)
        syncFonts()
        preview.layout = layout
    }
    @IBAction func labelFontSizeChange(_ sender: Any) {
        updateFonts(in: labelFontPickerGrid, size: labelFontSizePicker, to: \SquirrelLayout.labelFonts)
        preview.layout = layout
    }
    @IBAction func commentFontSizeChange(_ sender: Any) {
        updateFonts(in: commentFontPickerGrid, size: commentFontSizePicker, to: \SquirrelLayout.commentFonts)
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
    @IBAction func extraExpansionChanged(_ sender: Any) {
        layout.surroundingExtraExpansion = CGFloat(extraExpansionField.doubleValue)
        preview.layout = layout
    }
    @IBAction func windowAlphaChanged(_ sender: Any) {
        layout.alpha = CGFloat(windowAlphaField.doubleValue)
        preview.layout = layout
    }
    @IBAction func shadowSizeChanged(_ sender: Any) {
        layout.shadowSize = CGFloat(shadowSizeField.doubleValue)
        preview.layout = layout
    }
    @IBAction func showPreview(_ sender: Any) {
        preview.position = view.window!.convertToScreen(view.frame)
        if preview.isVisible {
            preview.hide()
            showPreviewButton.title = NSLocalizedString("Show Preview", comment: "Show Preview")
        } else {
            preview.updateAndShow()
            showPreviewButton.title = NSLocalizedString("Hide Preview", comment: "Hide Preview")
        }
    }
    @IBAction func resetPressed(_ sender: Any) {
        reset()
        preview.layout = layout
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
                generateCodeButton.title = NSLocalizedString("Hide Code", comment: "Hide Code")
            }
        } else {
            childWindow!.close()
            childWindow = nil
            generateCodeButton.title = NSLocalizedString("Show Code", comment: "Show Code")
        }
    }
    
    func syncFonts() {
        if labelFontToggle.state == .off {
            labelFontPicker.selectItem(withTitle: fontPicker.titleOfSelectedItem!)
            populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
            labelFontStylePicker.selectItem(at: fontStylePicker.indexOfSelectedItem)
            while labelFontPickerGrid.numberOfRows > fontPickerGrid.numberOfRows{
                deleteRow(labelFontPickerGrid.row(at: labelFontPickerGrid.numberOfRows - 1), in: labelFontPickerGrid)
            }
            while labelFontPickerGrid.numberOfRows < fontPickerGrid.numberOfRows{
                addRow(in: labelFontPickerGrid)
            }
            if fontPickerGrid.numberOfRows > 1 {
                for i in 1..<fontPickerGrid.numberOfRows {
                    if let fontPopup = fontPickerGrid.row(at: i).cell(at: 0).contentView as? FontPopUpButton,
                       let labelFontPopup = labelFontPickerGrid.row(at: i).cell(at: 0).contentView as? FontPopUpButton {
                        labelFontPopup.selectItem(withTitle: fontPopup.titleOfSelectedItem!)
                        populateFontMember(labelFontPopup.fontTraits!, inFamily: labelFontPopup)
                        labelFontPopup.fontTraits!.selectItem(at: fontPopup.fontTraits!.indexOfSelectedItem)
                    }
                }
                labelFontToggled(labelFontToggle!)
            }
            labelFontSizePicker.doubleValue = fontSizePicker.doubleValue
        }
        if commentFontToggle.state == .off {
            commentFontPicker.selectItem(withTitle: fontPicker.titleOfSelectedItem!)
            populateFontMember(commentFontStylePicker, inFamily: commentFontPicker)
            commentFontStylePicker.selectItem(at: fontStylePicker.indexOfSelectedItem)
            while commentFontPickerGrid.numberOfRows > fontPickerGrid.numberOfRows{
                deleteRow(commentFontPickerGrid.row(at: commentFontPickerGrid.numberOfRows - 1), in: commentFontPickerGrid)
            }
            while commentFontPickerGrid.numberOfRows < fontPickerGrid.numberOfRows{
                addRow(in: commentFontPickerGrid)
            }
            if fontPickerGrid.numberOfRows > 1 {
                for i in 1..<fontPickerGrid.numberOfRows {
                    if let fontPopup = fontPickerGrid.row(at: i).cell(at: 0).contentView as? FontPopUpButton,
                       let commentFontPopup = commentFontPickerGrid.row(at: i).cell(at: 0).contentView as? FontPopUpButton {
                        commentFontPopup.selectItem(withTitle: fontPopup.titleOfSelectedItem!)
                        populateFontMember(commentFontPopup.fontTraits!, inFamily: commentFontPopup)
                        commentFontPopup.fontTraits!.selectItem(at: fontPopup.fontTraits!.indexOfSelectedItem)
                    }
                }
                commentFontToggled(commentFontToggle!)
            }
            commentFontSizePicker.doubleValue = fontSizePicker.doubleValue
        }
    }
    func readFont(family: NSPopUpButton, style: NSPopUpButton, size: NSTextField) -> NSFont? {
        let fontFamily: String = family.titleOfSelectedItem!
        let fontTraits: String = style.titleOfSelectedItem!
        if let fontSize = Double(size.stringValue) {
            if let font = NSFont(name: "\(fontFamily.filter {!$0.isWhitespace})-\(fontTraits.filter {!$0.isWhitespace})", size: CGFloat(fontSize)) {
                return font
            }
            let members = NSFontManager.shared.availableMembers(ofFontFamily: fontFamily) ?? [[Any]]()
            for i in 0..<members.count {
                if let memberName = members[i][1] as? String, memberName == fontTraits,
                    let weight = members[i][2] as? Int,
                    let traits = members[i][3] as? UInt {
                    return NSFontManager.shared.font(withFamily: fontFamily, traits: NSFontTraitMask(rawValue: traits), weight: weight, size: CGFloat(fontSize))
                }
            }
            if let font = NSFont(name: fontFamily, size: CGFloat(fontSize)) {
                return font
            }
        }
        return nil
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
    func clearAdditionalFont(in grid: NSGridView) {
        if grid.numberOfRows > 1 {
            for i in 1..<grid.numberOfRows {
                deleteRow(grid.row(at: grid.numberOfRows - i), in: grid)
            }
        }
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
        picker.selectItem(at: 0)
    }
    func updateUI() {
        nameField.stringValue = layout.name
        fontPicker.selectItem(withTitle: layout.fonts[0].familyName!)
        populateFontMember(fontStylePicker, inFamily: fontPicker)
        if let traits = layout.fonts[0].fontName.split(separator: "-").last {
            fontStylePicker.selectItem(withTitle: String(traits))
        }
        if fontStylePicker.selectedItem == nil {
            fontStylePicker.selectItem(at: 0)
        }
        fontSizePicker.stringValue = "\(layout.fonts[0].pointSize)"
        clearAdditionalFont(in: fontPickerGrid)
        if layout.fonts.count > 1 {
            for font in layout.fonts[1...] {
                addRow(in: fontPickerGrid)
                if let _fontPicker = fontPickerGrid.cell(atColumnIndex: 0, rowIndex: fontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton,
                   let _fontStylePicker = fontPickerGrid.cell(atColumnIndex: 1, rowIndex: fontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton {
                    _fontPicker.selectItem(withTitle: font.familyName!)
                    populateFontMember(_fontStylePicker, inFamily: _fontPicker)
                    if let traits = font.fontName.split(separator: "-").last {
                        _fontStylePicker.selectItem(withTitle: String(traits))
                    }
                    if _fontStylePicker.selectedItem == nil {
                        _fontStylePicker.selectItem(at: 0)
                    }
                }
            }
        }
        if !layout.labelFonts.isEmpty {
            labelFontPicker.selectItem(withTitle: layout.labelFonts[0].familyName!)
            populateFontMember(labelFontStylePicker, inFamily: labelFontPicker)
            if let traits = layout.labelFont?.fontName.split(separator: "-").last {
                labelFontStylePicker.selectItem(withTitle: String(traits))
            }
            if labelFontStylePicker.selectedItem == nil {
                labelFontStylePicker.selectItem(at: 0)
            }
            labelFontSizePicker.stringValue = "\(layout.labelFonts[0].pointSize)"
            clearAdditionalFont(in: labelFontPickerGrid)
            if layout.labelFonts.count > 1 {
                for font in layout.labelFonts[1...] {
                    addRow(in: labelFontPickerGrid)
                    if let _fontPicker = labelFontPickerGrid.cell(atColumnIndex: 0, rowIndex: labelFontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton,
                       let _fontStylePicker = labelFontPickerGrid.cell(atColumnIndex: 1, rowIndex: labelFontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton {
                        _fontPicker.selectItem(withTitle: font.familyName!)
                        populateFontMember(_fontStylePicker, inFamily: _fontPicker)
                        if let traits = font.fontName.split(separator: "-").last {
                            _fontStylePicker.selectItem(withTitle: String(traits))
                        }
                        if _fontStylePicker.selectedItem == nil {
                            _fontStylePicker.selectItem(at: 0)
                        }
                    }
                }
            }
            labelFontToggle.state = .on
            labelFontToggled(labelFontToggle!)
        } else {
            labelFontToggle.state = .off
            labelFontToggled(labelFontToggle!)
            syncFonts()
        }
        
        if !layout.commentFonts.isEmpty {
            commentFontPicker.selectItem(withTitle: layout.commentFonts[0].familyName!)
            populateFontMember(commentFontStylePicker, inFamily: commentFontPicker)
            if let traits = layout.commentFont?.fontName.split(separator: "-").last {
                commentFontStylePicker.selectItem(withTitle: String(traits))
            }
            if commentFontStylePicker.selectedItem == nil {
                commentFontStylePicker.selectItem(at: 0)
            }
            commentFontSizePicker.stringValue = "\(layout.commentFonts[0].pointSize)"
            clearAdditionalFont(in: commentFontPickerGrid)
            if layout.commentFonts.count > 1 {
                for font in layout.commentFonts[1...] {
                    addRow(in: commentFontPickerGrid)
                    if let _fontPicker = commentFontPickerGrid.cell(atColumnIndex: 0, rowIndex: commentFontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton,
                       let _fontStylePicker = commentFontPickerGrid.cell(atColumnIndex: 1, rowIndex: commentFontPickerGrid.numberOfRows-1).contentView as? NSPopUpButton {
                        _fontPicker.selectItem(withTitle: font.familyName!)
                        populateFontMember(_fontStylePicker, inFamily: _fontPicker)
                        if let traits = font.fontName.split(separator: "-").last {
                            _fontStylePicker.selectItem(withTitle: String(traits))
                        }
                        if _fontStylePicker.selectedItem == nil {
                            _fontStylePicker.selectItem(at: 0)
                        }
                    }
                }
            }
            commentFontToggle.state = .on
            commentFontToggled(commentFontToggle!)
        } else {
            commentFontToggle.state = .off
            commentFontToggled(labelFontToggle!)
            syncFonts()
        }

        
        candidateListLayoutSwitch.selectSegment(withTag: layout.linear ? 1 : 0)
        textOrientationSwitch.selectSegment(withTag: layout.vertical ? 1 : 0)
        preeditPositionSwitch.selectSegment(withTag: layout.inlinePreedit ? 1 : 0)
        translucencySwitch.selectSegment(withTag: layout.translucency ? 1 : 0)
        MutualExclusiveSwitch.selectSegment(withTag: layout.mutualExclusive ? 1 : 0)
        if layout.isDisplayP3 {
            colorSpacePicker.selectItem(at: 1)
        } else {
            colorSpacePicker.selectItem(at: 0)
        }
        backgroundColorPicker.color = layout.backgroundColor!
        candidateTextColorPicker.color = layout.candidateTextColor!
        candidateBackColorToggle.state = layout.stripColor == nil ? .off : .on
        if let candidateBackColor = layout.stripColor {
            candidateBackColorPicker.isEnabled = true
            candidateBackColorPicker.color = candidateBackColor
        } else {
            candidateBackColorPicker.isEnabled = false
            candidateBackColorPicker.color = NSColor(white: 1, alpha: 0)
        }
        hilitedCandidateBackColorPicker.color = layout.highlightedStripColor!
        hilitedCandidateTextColorPicker.color = layout.highlightedCandidateTextColor!
        preeditBackColorToggle.state = layout.preeditBackgroundColor == nil ? .off : .on
        if let preeditBackgroundColor = layout.preeditBackgroundColor {
            preeditBackColorPicker.color = preeditBackgroundColor
            preeditBackColorPicker.isEnabled = true
        } else {
            preeditBackColorPicker.isEnabled = false
        }
        preeditTextColorPicker.color = layout.textColor!
        hilitedPreeditBackColorToggle.state = layout.highlightedPreeditColor == nil ? .off : .on
        if let highlightedPreeditColor = layout.highlightedPreeditColor {
            hilitedPreeditBackColorPicker.color = highlightedPreeditColor
            hilitedPreeditBackColorPicker.isEnabled = true
        } else {
            hilitedPreeditBackColorPicker.isEnabled = false
        }
        hilitedPreeditTextColorPicker.color = layout.highlightedTextColor!
        borderColorToggle.state = layout.borderColor == nil ? .off : .on
        if let borderColor = layout.borderColor {
            borderColorPicker.color = borderColor
            borderColorPicker.isEnabled = true
        } else {
            borderColorPicker.isEnabled = false
        }
        commentTextColorPicker.color = layout.commentTextColor!
        hilitedCommentTextColorToggle.state = layout.highlightedCommentTextColor == nil ? .off : .on
        if let highlightedCommentTextColor = layout.highlightedCommentTextColor {
            hilitedCommentTextColorPicker.color = highlightedCommentTextColor
            hilitedCommentTextColorPicker.isEnabled = true
        } else {
            hilitedCommentTextColorPicker.isEnabled = false
        }
        labelTextColorToggle.state = layout.candidateLabelColor == nil ? .off : .on
        if let candidateLabelColor = layout.candidateLabelColor {
            labelTextColorPicker.color = candidateLabelColor
            labelTextColorPicker.isEnabled = true
        } else {
            labelTextColorPicker.isEnabled = false
        }
        hilitedLabelTextColorToggle.state = layout.highlightedCandidateLabelColor == nil ? .off : .on
        if let highlightedCandidateLabelColor = layout.highlightedCandidateLabelColor {
            hilitedLabelTextColorPicker.color = highlightedCandidateLabelColor
            hilitedLabelTextColorPicker.isEnabled = true
        } else {
            hilitedLabelTextColorPicker.isEnabled = false
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
        extraExpansionField.stringValue = "\(layout.surroundingExtraExpansion)"
        windowAlphaField.stringValue = "\(layout.alpha)"
        shadowSizeField.stringValue = "\(layout.shadowSize)"
    }
    func codeViewDidDispear() {
        generateCodeButton.title = NSLocalizedString("Show Code", comment: "Show Code")
    }
    func reset() {
        layout = SquirrelLayout(new: false)
        populateFontFamilies(fontPicker)
        populateFontFamilies(labelFontPicker)
        populateFontFamilies(commentFontPicker)
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Layout")
        if let fetchedEntities = try? managedContext.fetch(fetchRequest),
            let savedLayout = fetchedEntities.last?.value(forKey: "code") as? String {
            SquirrelLayout.template = savedLayout
            if fetchedEntities.count > 1 {
                for i in 0..<(fetchedEntities.count-1) {
                    managedContext.delete(fetchedEntities[i])
                }
            }

        }
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Input")
        if let fetchedEntities = try? managedContext.fetch(fetchRequest),
            let savedInput = fetchedEntities.last?.value(forKey: "code") as? String {
            InputSource.template = savedInput
            if fetchedEntities.count > 1 {
                for i in 0..<(fetchedEntities.count-1) {
                    managedContext.delete(fetchedEntities[i])
                }
            }
        }
        
        reset()
        let rowHeight = fontPickerGrid.rowSpacing + fontPickerGrid.row(at: 0).height
        let fontRow = fontPickerGrid.numberOfRows - 1
        let labelFontRow = labelFontPickerGrid.numberOfRows - 1
        let commentFontRow = commentFontPickerGrid.numberOfRows - 1
        for grid in [fontPickerGrid, labelFontPickerGrid, commentFontPickerGrid] {
            shift(grid, x: nil, y: -CGFloat(fontRow + labelFontRow + commentFontRow) * rowHeight)
        }
        for ui in [labelFontUIString, labelFontToggle, labelFontSizeUIString, labelFontSizePicker] {
            shift(ui, x: nil, y: CGFloat(labelFontRow + commentFontRow) * rowHeight)
        }
        for ui in [commentFontUIString, commentFontToggle, commentFontSizeUIString,
                   commentFontSizePicker] {
            shift(ui, x: nil, y: CGFloat(commentFontRow) * rowHeight)
        }
        scrollToTop()
        preview.layout = layout
        preview.parentView = self
        preview.setup(input: inputSource)
        NSColorPanel.shared.showsAlpha = true
        NSColorPanel.shared.mode = .RGB
        Self.currentInstance = self
    }
    
    override func viewDidDisappear() {
        NSColorPanel.shared.showsAlpha = false
        NSColorPanel.shared.mode = .wheel
        Self.currentInstance = nil
        mainWindowFrame = view.window!.convertToScreen(view.frame)
        exit(0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

