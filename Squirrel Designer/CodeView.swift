//
//  CodeView.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 9/1/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

class CodeViewController: NSViewController {
    @IBOutlet weak var codeField: NSTextView!
    @IBOutlet weak var generateCodeButton: NSButton!
    @IBOutlet weak var readCodeButton: NSButton!
    weak var parentView: ViewController?
    
    
    @IBAction func generateCodeButtonPressed(_ sender: Any) {
        codeField.string = layout.encode()
    }
    @IBAction func readCodeButtonPressed(_ sender: Any) {
        layout.decode(from: codeField.string)
        preview.layout = layout
        parentView?.updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.string = layout.encode()
        codeField.textStorage?.font = NSFont.userFont(ofSize: 15)!
    }
    override func viewDidDisappear() {
        if let parent = parentView {
            parent.generateCodeButton.title = "Show Code"
        }
    }
}
