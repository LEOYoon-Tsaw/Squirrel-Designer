//
//  CodeView.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 9/1/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

func saveLayoutCode(_ code: String) {
    guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    let layoutEntity = NSEntityDescription.entity(forEntityName: "Layout", in: managedContext)!
    let savedLayout = NSManagedObject(entity: layoutEntity, insertInto: managedContext)
    savedLayout.setValue(code, forKey: "code")
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
}

class CodeViewController: NSViewController {
    @IBOutlet weak var codeField: NSTextView!
    @IBOutlet weak var generateCodeButton: NSButton!
    @IBOutlet weak var readCodeButton: NSButton!
    weak var parentView: ViewController?
    static weak var currentInstance: CodeViewController?
    
    
    @IBAction func generateCodeButtonPressed(_ sender: Any) {
        codeField.string = layout.encode()
        saveLayoutCode(codeField.string)
    }
    @IBAction func readCodeButtonPressed(_ sender: Any) {
        layout.decode(from: codeField.string)
        preview.layout = layout
        parentView?.updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.string = layout.encode()
        codeField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        codeField.drawsBackground = false
        saveLayoutCode(codeField.string)
        Self.currentInstance = self
    }
    override func viewDidDisappear() {
        if let parent = parentView {
            parent.generateCodeButton.title = NSLocalizedString("Show Code", comment: "Show Code")
        }
        Self.currentInstance = nil
    }
}
