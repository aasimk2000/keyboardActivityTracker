//
//  DetailsViewController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/12/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

protocol DetailsWindowDelegate {
    func detailsDidUpdate()
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
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(targetText.integerValue, forKey: "target")
        delegate?.detailsDidUpdate()
    }
    
}
