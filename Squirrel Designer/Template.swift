//
//  Template.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 9/1/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

func saveInputCode(_ code: String) {
    guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    let inputEntity = NSEntityDescription.entity(forEntityName: "Input", in: managedContext)!
    let savedInput = NSManagedObject(entity: inputEntity, insertInto: managedContext)
    savedInput.setValue(code, forKey: "code")
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
}

class InputSource {
    static var template: String?
    
    var preedit = "漢皇重色思傾國竹人人止中 十一木 弓戈弓戈 人手 戈十水 一火 竹人日一戈 木日一竹 十一尸人 大月 女 中尸竹 尸一女 戈竹尸 廿人戈日女 大中土 水月金木 日弓土土‸ojdyryia"
    var selRange = NSMakeRange(7, 77)
    var candidates: Array<String> = ["御宇多年求不得楊家有女初長成養在深閨", "御宇多年求不得", "御宇多年", "御宇", "御", "八"]
    var comments: Array<String> = ["", "", "", "", "疑依模去、疑娃歌去", "幫娃先入"]
    var labels: Array<String> = ["〡", "〢", "〣", "〤", "〥", "〦", "〧", "〨", "〩"]
    var index: UInt = 0
    var candidateFormat = "%c. %@"
    
    init() {
        if let template = Self.template {
            self.decode(from: template)
        }
    }
    
    func encode() -> String {
        var encoded = ""
        encoded += "preedit: \(preedit)\n"
        encoded += "sel_range: \(selRange.lowerBound)-\(selRange.upperBound)\n"
        encoded += "candidates: \(candidates.joined(separator: " , "))\n"
        encoded += "comments: \(comments.joined(separator: " , "))\n"
        encoded += "labels: \(labels.joined(separator: " , "))\n"
        encoded += "index: \(index)\n"
        encoded += "candidate_format: \(candidateFormat)"
        return encoded
    }
    
    func decode(from string: String) {
        let regex = try! NSRegularExpression(pattern: "([a-z_0-9]+): ?(.+)$", options: .caseInsensitive)
        var values = Dictionary<String, String>()
        for line in string.split(whereSeparator: \.isNewline) {
            let line = String(line)
            let matches = regex.matches(in: line, options: .init(rawValue: 0), range: NSMakeRange(0, line.endIndex.utf16Offset(in: line)))
            for match in matches {
                values[(line as NSString).substring(with: match.range(at: 1))] = (line as NSString).substring(with: match.range(at: 2))
            }
        }
        let preedit = values["preedit"]
        var selRange: NSRange?
        if let rangeString = values["sel_range"]?.split(separator: "-"),
            let lowerString = rangeString.first,
            let upperString = rangeString.last,
            let lower = Int(lowerString),
            let upper = Int(upperString)
        {
            if let preedit = preedit {
                if upper > preedit.endIndex.utf16Offset(in: preedit) {
                    selRange = NSMakeRange(lower, preedit.endIndex.utf16Offset(in: preedit)-lower)
                } else {
                    selRange = NSMakeRange(lower, upper-lower)
                }
            } else {
                selRange = NSMakeRange(NSNotFound, 0)
            }
            if selRange != nil && selRange!.length <= 0 {
                selRange = NSMakeRange(NSNotFound, 0)
            }
        }
        var candidates = Array<String>()
        if let candidatesString = values["candidates"] {
            for candidateString in candidatesString.split(separator: ",") {
                candidates.append(candidateString.trimmingCharacters(in: .whitespaces))
            }
        }
        var comments = Array<String>()
        if let commentsString = values["comments"] {
            for commentString in commentsString.split(separator: ",") {
                comments.append(commentString.trimmingCharacters(in: .whitespaces))
            }
        }
        var labels = Array<String>()
        if let labelsString = values["labels"] {
            for labelString in labelsString.split(separator: ",") {
                labels.append(labelString.trimmingCharacters(in: .whitespaces))
            }
        }
        var index: UInt?
        if let indexString = values["index"],
            let _index = UInt(indexString) {
            index = _index
        }
        let candidateFormat = values["candidate_format"]
        
        self.preedit = preedit == nil ? "" : preedit!
        self.selRange = selRange == nil ? NSMakeRange(NSNotFound, 0) : selRange!
        self.candidates = candidates.isEmpty ? self.candidates : candidates
        self.comments = comments.isEmpty ? self.comments : comments
        self.labels = labels.isEmpty ? self.labels : labels
        self.index = index == nil ? 0 : index!
        self.candidateFormat = candidateFormat == nil ? self.candidateFormat : candidateFormat!
    }
}

class SettingViewController: NSViewController {
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var preeditToggle: NSSwitch!
    @IBOutlet weak var preeditLeading: NSTextField!
    @IBOutlet weak var preeditHighlighted: NSTextField!
    @IBOutlet weak var preedittrailing: NSTextField!
    @IBOutlet weak var candidateFormatField: NSTextField!
    @IBOutlet weak var labelsGrid: NSGridView!
    @IBOutlet weak var candidatesGrid: NSGridView!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var initialSelector: NSButton!
    
    @IBAction func closeWindow(_ sender: Any) {
        self.view.window?.close()
    }
    @IBAction func preeditToggled(_ sender: Any) {
        if preeditToggle.state == .on {
            preeditLeading.isEnabled = true
            preeditHighlighted.isEnabled = true
            preedittrailing.isEnabled = true
        } else {
            preeditLeading.isEnabled = false
            preeditHighlighted.isEnabled = false
            preedittrailing.isEnabled = false
        }
    }
    
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
    func getAnother(_ current: NSGridView, in parentView: NSView) -> NSGridView? {
        for subview in parentView.subviews {
            if let subview = (subview as? NSGridView), subview != current {
                return subview
            }
        }
        return nil
    }
    func deleteRow(_ row: NSGridRow?, in grid: NSGridView?) {
        guard let grid = grid else { return }
        let rowHeight = grid.rowSpacing + grid.row(at: 0).height
        if let row = row {
            row.isHidden = true
            let rowIndex = grid.index(of: row)
            if let previousSelector = grid.cell(atColumnIndex: 0, rowIndex: rowIndex - 1).contentView as? NSButton,
                let currentSelector = row.cell(at: 0).contentView as? NSButton,
                currentSelector.state == .on
            {
                previousSelector.state = .on
            }
            grid.removeRow(at: rowIndex)
            resize(grid, width: nil, height: grid.frame.height - rowHeight)
            let anotherGrid = getAnother(grid, in: contentView)
            if grid.frame.size.height >= anotherGrid!.frame.size.height {
                shift(anotherGrid, x: nil, y: -rowHeight)
                let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
                resize(contentView, width: nil, height: contentView.frame.height - rowHeight)
                contentView.scroll(NSPoint(x: 0, y: max(0, viewPoint.y - rowHeight)))
            } else {
                shift(grid, x: nil, y: rowHeight)
                let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
                contentView.scroll(NSPoint(x: 0, y: max(0, viewPoint.y)))
            }
        }
    }
    @objc func deleteInputRow(sender: FontDeleteButton) {
        deleteRow(sender.residenceRow, in: sender.residenceRow?.gridView)
    }
    @objc func highlightSelection(_ sender: NSButton) {
        
    }
    func labelsGridAddRow() {
        let cellHeight = labelsGrid.row(at: 0).height
        let rowHeight = labelsGrid.rowSpacing + cellHeight
        let columnWidth = labelsGrid.column(at: 0).width
        let labelField = NSTextField()
        labelField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        resize(labelField, width: columnWidth, height: nil)
        let deleteButton = FontDeleteButton()
        deleteButton.title = ""
        deleteButton.setButtonType(.switch)
        deleteButton.bezelStyle = .circular
        deleteButton.isBordered = true
        deleteButton.image = NSImage(named: NSImage.removeTemplateName)
        deleteButton.imagePosition = .imageOverlaps
        resize(deleteButton, width: cellHeight, height: cellHeight)
        labelsGrid.addRow(with: [labelField, deleteButton])
        labelsGrid.row(at: labelsGrid.numberOfRows-1).height = cellHeight
        deleteButton.residenceRow = labelsGrid.row(at: labelsGrid.numberOfRows-1)
        deleteButton.action = #selector(SettingViewController.deleteInputRow(sender:))
        if labelsGrid.frame.size.height >= candidatesGrid.frame.size.height - 1 {
            shift(candidatesGrid, x: nil, y: rowHeight)
            resize(contentView, width: nil, height: contentView.frame.height + rowHeight)
            let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
            contentView.scroll(NSPoint(x: 0, y: viewPoint.y + rowHeight))
        } else {
            shift(labelsGrid, x: nil, y: -rowHeight)
            let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
            contentView.scroll(NSPoint(x: 0, y: viewPoint.y))
        }
    }
    @IBAction func labelsGridAddRow(_ sender: Any) {
        labelsGridAddRow()
    }
    func candidatesGridAddRow() {
        let cellHeight = candidatesGrid.row(at: 0).height
        let rowHeight = candidatesGrid.rowSpacing + cellHeight
        let columnWidth = candidatesGrid.column(at: 0).width
        let toggle = NSButton(title: "", target: nil, action: #selector(SettingViewController.highlightSelection(_:)))
        toggle.setButtonType(.radio)
        let candidateField = NSTextField()
        candidateField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        resize(candidateField, width: columnWidth, height: nil)
        let commentField = NSTextField()
        commentField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        resize(commentField, width: columnWidth, height: nil)
        let deleteButton = FontDeleteButton()
        deleteButton.title = ""
        deleteButton.setButtonType(.switch)
        deleteButton.bezelStyle = .circular
        deleteButton.isBordered = true
        deleteButton.image = NSImage(named: NSImage.removeTemplateName)
        deleteButton.imagePosition = .imageOverlaps
        resize(deleteButton, width: cellHeight, height: cellHeight)
        candidatesGrid.addRow(with: [toggle, candidateField, commentField, deleteButton])
        candidatesGrid.row(at: candidatesGrid.numberOfRows-1).height = cellHeight
        deleteButton.residenceRow = candidatesGrid.row(at: candidatesGrid.numberOfRows-1)
        deleteButton.action = #selector(SettingViewController.deleteInputRow(sender:))
        if candidatesGrid.frame.size.height >= labelsGrid.frame.size.height {
            shift(labelsGrid, x: nil, y: rowHeight)
            resize(contentView, width: nil, height: contentView.frame.height + rowHeight)
            let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
            contentView.scroll(NSPoint(x: 0, y: viewPoint.y + rowHeight))
        } else {
            shift(candidatesGrid, x: nil, y: -rowHeight)
            let viewPoint = view.convert(scrollView.frame.origin, to: contentView)
            contentView.scroll(NSPoint(x: 0, y: viewPoint.y))
        }
    }
    @IBAction func candidatesGridAddRow(_ sender: Any) {
        candidatesGridAddRow()
    }
    @IBAction func reset(_ sender: Any) {
        inputSource = InputSource()
        if labelsGrid.numberOfRows > 1 {
            for _ in 1..<labelsGrid.numberOfRows {
                deleteRow(labelsGrid.row(at: labelsGrid.numberOfRows - 1), in: labelsGrid)
            }
        }
        if candidatesGrid.numberOfRows > 1 {
            for _ in 1..<candidatesGrid.numberOfRows {
                deleteRow(candidatesGrid.row(at: candidatesGrid.numberOfRows - 1), in: candidatesGrid)
            }
        }
        updateUI()
        let rowHeight = candidatesGrid.rowSpacing + candidatesGrid.row(at: 0).height
        let offset: CGFloat = rowHeight * CGFloat(min(labelsGrid.numberOfRows, candidatesGrid.numberOfRows) - 1)
        resize(contentView, width: nil, height: contentView.frame.height - offset)
        shift(labelsGrid, x: nil, y: -offset)
        shift(candidatesGrid, x: nil, y: -offset)
    }
    @IBAction func save(_ sender: Any) {
        loadData()
        self.view.window?.close()
        preview.setup(input: inputSource)
        if preview.isVisible {
            preview.layout = layout
        }
        saveInputCode(inputSource.encode())
    }
    func loadData() {
        if preeditToggle.state == .on {
            inputSource.preedit = preeditLeading.stringValue + preeditHighlighted.stringValue + "‸" + preedittrailing.stringValue
            inputSource.selRange = NSMakeRange(preeditLeading.stringValue.utf16.count,
                                               preeditHighlighted.stringValue.utf16.count)
        } else {
            inputSource.preedit = ""
            inputSource.selRange = NSMakeRange(NSNotFound, 0)
        }
        inputSource.candidates = Array<String>()
        inputSource.comments = Array<String>()
        for i in 0..<candidatesGrid.numberOfRows {
            if let selectButton = candidatesGrid.cell(atColumnIndex: 0, rowIndex: i).contentView as? NSButton,
                let candidateField = candidatesGrid.cell(atColumnIndex: 1, rowIndex: i).contentView as? NSTextField,
                let commentField = candidatesGrid.cell(atColumnIndex: 2, rowIndex: i).contentView as? NSTextField
            {
                if selectButton.state == .on {
                    inputSource.index = UInt(i)
                }
                inputSource.candidates.append(candidateField.stringValue)
                inputSource.comments.append(commentField.stringValue)
            }
        }
        inputSource.labels = Array<String>()
        for i in 0..<labelsGrid.numberOfRows {
            if let labelField = labelsGrid.cell(atColumnIndex: 0, rowIndex: i).contentView as? NSTextField {
                inputSource.labels.append(labelField.stringValue)
            }
        }
        inputSource.candidateFormat = candidateFormatField.stringValue
    }
    
    func updateUI() {
        if inputSource.preedit.isEmpty {
            preeditToggle.state = .off
            preeditToggled(preeditToggle!)
        } else {
            preeditToggle.state = .on
            preeditToggled(preeditToggle!)
            preeditLeading.stringValue = (inputSource.preedit as NSString).substring(to: inputSource.selRange.location)
            preeditHighlighted.stringValue = (inputSource.preedit as NSString).substring(with: inputSource.selRange)
            preedittrailing.stringValue = (inputSource.preedit as NSString).substring(from: NSMaxRange(inputSource.selRange) + 1)
        }
        candidateFormatField.stringValue = inputSource.candidateFormat
        if inputSource.labels.count > 0 {
            for i in 0..<inputSource.labels.count {
                if i > 0 {
                    labelsGridAddRow()
                }
                if let textField = labelsGrid.cell(atColumnIndex: 0, rowIndex: i).contentView as? NSTextField {
                    textField.stringValue = inputSource.labels[i]
                }
            }
        }
        if max(inputSource.candidates.count, inputSource.comments.count) > 0 {
            shift(candidatesGrid, x: nil, y: -labelsGrid.frame.height+candidatesGrid.frame.height)
            for i in 0..<max(inputSource.candidates.count, inputSource.comments.count) {
                if i > 0 {
                    candidatesGridAddRow()
                }
                if let textField = candidatesGrid.cell(atColumnIndex: 1, rowIndex: i).contentView as? NSTextField,
                    i < inputSource.candidates.count {
                    textField.stringValue = inputSource.candidates[i]
                }
                if let textField = candidatesGrid.cell(atColumnIndex: 2, rowIndex: i).contentView as? NSTextField,
                    i < inputSource.comments.count {
                    textField.stringValue = inputSource.comments[i]
                }
            }
        }
        if inputSource.index < candidatesGrid.numberOfRows,
            let selected = candidatesGrid.cell(atColumnIndex: 0, rowIndex: Int(inputSource.index)).contentView as? NSButton {
            selected.state = .on
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        let rowHeight = candidatesGrid.rowSpacing + candidatesGrid.row(at: 0).height
        shift(labelsGrid, x: nil, y: labelsGrid.frame.height+candidatesGrid.frame.height)
        shift(candidatesGrid, x: nil, y: labelsGrid.frame.height+candidatesGrid.frame.height)
        resize(labelsGrid, width: nil, height: labelsGrid.frame.size.height + rowHeight * CGFloat(inputSource.labels.count - 1))
        resize(candidatesGrid, width: nil, height: candidatesGrid.frame.size.height + rowHeight * CGFloat(max(inputSource.candidates.count, inputSource.comments.count) - 1))
        shift(labelsGrid, x: nil, y: -labelsGrid.frame.height-candidatesGrid.frame.height)
        shift(candidatesGrid, x: nil, y: -labelsGrid.frame.height-candidatesGrid.frame.height)
        resize(contentView, width: nil, height: contentView.frame.height - min(labelsGrid.frame.height, candidatesGrid.frame.height) + labelsGrid.rowSpacing)
        initialSelector.action = #selector(SettingViewController.highlightSelection(_:))
    }
}
