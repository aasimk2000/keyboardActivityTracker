//
//  DetailsViewController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/12/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import os

protocol DetailsWindowDelegate {
    func detailsDidUpdate()
    
    func exportString() -> String
    
    func getCurrentTarget() -> Int
}

class DetailsViewController: NSWindowController, NSWindowDelegate {
    
    override var windowNibName : String! {
        return "DetailsViewController"
    }

    @IBOutlet weak var targetText: NSTextField!
    var delegate: DetailsWindowDelegate?
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        targetText.integerValue = delegate?.getCurrentTarget() ?? 2000
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(targetText.integerValue, forKey: "target")
        delegate?.detailsDidUpdate()
    }
    
    @IBAction func exportClicked(_ sender: Any) {
        let textToExport = delegate?.exportString()
        if textToExport != "" {
            let mySave = NSSavePanel()
            mySave.allowedFileTypes = ["csv"]
            mySave.isExtensionHidden = false
            
            mySave.begin { (result) -> Void in
                
                if result == NSApplication.ModalResponse.OK {
                    let filename = mySave.url
                    
                    do {
                        try textToExport?.write(to: filename!, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                        let alert = NSAlert()
                        alert.messageText = "Invalid file permission"
                        alert.informativeText = "Please check file permissions at destination"
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                    
                } else {
                    NSSound.beep()
                }
            }
        }
    }
}
