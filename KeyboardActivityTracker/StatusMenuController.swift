//
//  StatusMenuController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let keyboardTracker = KeyboardTracker()
    
    override func awakeFromNib() {
        if let button = statusItem.button {
            button.title = "💩"
            statusItem.menu = statusMenu
        }
        
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access not Enabled")
        }
        keyboardTracker.monintorEvent()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)

    }
    
    @IBAction func printKeyStrokes(_ sender: NSMenuItem) {
        keyboardTracker.printKeypresses()
    }
}
