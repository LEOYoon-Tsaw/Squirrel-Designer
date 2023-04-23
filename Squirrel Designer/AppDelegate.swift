//
//  AppDelegate.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if ViewController.currentInstance == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let windowController = storyboard.instantiateController(withIdentifier: "Main Window Controller") as! NSWindowController
            if let mainWindow = windowController.window {
                windowController.showWindow(sender)
                if let frame = mainWindowFrame {
                    mainWindow.setFrameOrigin(frame.origin)
                }
                if let codeView = CodeViewController.currentInstance {
                    (mainWindow.contentViewController as! ViewController).childWindow = codeView.view.window?.windowController
                    (mainWindow.contentViewController as! ViewController).generateCodeButton.title = NSLocalizedString("Hide Code", comment: "Hide Code")
                }
                if preview.isVisible {
                    (mainWindow.contentViewController as! ViewController).showPreviewButton.title = NSLocalizedString("Hide Preview", comment: "Hide Preview")
                }
            }
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SquirrelLayout")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    @IBAction func openFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["txt", "yaml"]
        panel.title = NSLocalizedString("Select Layout File", comment: "Open File")
        panel.message = NSLocalizedString("Warning: The current layout will be discarded!", comment: "Warning")
        panel.begin {
            result in
            if result == .OK, let file = panel.url {
                do {
                    let content = try String(contentsOf: file)
                    layout.decode(from: content)
                    preview.layout = layout
                    ViewController.currentInstance?.updateUI()
                    CodeViewController.currentInstance?.codeField.string = content
                    saveLayoutCode(content)
                } catch let error {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Load Failed", comment: "Load Failed")
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func saveFile(_ sender: Any) {
        let panel = NSSavePanel()
        panel.title = NSLocalizedString("Select File", comment: "Save File")
        panel.nameFieldStringValue = layout.name + ".txt"
        panel.begin() {
            result in 
            if result == .OK, let file = panel.url {
                do {
                    let codeString = layout.encode()
                    saveLayoutCode(codeString)
                    try codeString.data(using: .utf8)?.write(to: file, options: .atomicWrite)
                } catch let error {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Save Failed", comment: "Save Failed")
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func newLayout(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Reset Layout", comment: "")
        alert.informativeText = NSLocalizedString("Unsaved Work Will Be Lost! Do you want to proceed?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Abort", comment: "Abort"))
        alert.addButton(withTitle: NSLocalizedString("Proceed", comment: "Proceed"))
        if let window = ViewController.currentInstance?.view.window {
            alert.beginSheetModal(for: window) { result in
                if result == .alertSecondButtonReturn {
                    layout = SquirrelLayout(new: true)
                    ViewController.currentInstance?.updateUI()
                    CodeViewController.currentInstance?.codeField.string = layout.encode()
                }
            }
        }
    }
    
    @IBAction func openTemplateFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["txt", "yaml"]
        panel.title = NSLocalizedString("Select Template File", comment: "Open File")
        panel.message = NSLocalizedString("Warning: The current template will be discarded!", comment: "Warning")
        panel.begin {
            result in
            if result == .OK, let file = panel.url {
                do {
                    let content = try String(contentsOf: file)
                    inputSource.decode(from: content)
                    preview.setup(input: inputSource)
                    SettingViewController.currentInstance?.reloadUI()
                    preview.layout = layout
                    saveInputCode(content)
                } catch let error {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Load Failed", comment: "Load Failed")
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func saveTemplateFile(_ sender: Any) {
        let panel = NSSavePanel()
        panel.title = NSLocalizedString("Select File", comment: "Save File")
        panel.nameFieldStringValue = layout.name + "_template" + ".txt"
        panel.begin() {
            result in
            if result == .OK, let file = panel.url {
                do {
                    SettingViewController.currentInstance?.loadData()
                    let codeString = inputSource.encode()
                    saveInputCode(codeString)
                    try codeString.data(using: .utf8)?.write(to: file, options: .atomicWrite)
                } catch let error {
                    let alert = NSAlert()
                    alert.messageText = "Save Failed"
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func newTemplate(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Reset Template", comment: "")
        alert.informativeText = NSLocalizedString("Unsaved Work Will Be Lost! Do you want to proceed?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Abort", comment: "Abort"))
        alert.addButton(withTitle: NSLocalizedString("Proceed", comment: "Proceed"))
        if let window = SettingViewController.currentInstance?.view.window {
            alert.beginSheetModal(for: window) { result in
                if result == .alertSecondButtonReturn {
                    inputSource = InputSource(new: true)
                    preview.setup(input: inputSource)
                    SettingViewController.currentInstance?.reloadUI()
                }
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

