//
//  StatusMenuController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let keyboardTracker = KeyboardTracker()
    var color = GraphColor.orange
    let popover:NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        return popover
    }()
    
    deinit {
        keyboardTracker.eventMonitor?.stop()
    }
    
    override func awakeFromNib() {
        setUpStatusItem()
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access not Enabled")
        }
        
        keyboardTracker.monintorEvent()
        let defaults = UserDefaults.standard
        let colorInt = defaults.integer(forKey: "color")
        color = GraphColor(rawValue: colorInt) ?? GraphColor.orange
        // setUpDelegates()
    }
        
    func setUpStatusItem() {
        if let button = statusItem.button {
            button.title = "💩"
            button.target = self
            // statusItem.menu = statusMenu
        }
        statusItem.button?.action = #selector(buttonPressed)
    }
    
    @objc func buttonPressed(_ sender: Any?) {
        let vc = GraphPopVC(nibName: "GraphPopVC", bundle: nil)
        vc.graphPopDelegate = self
        guard let button = statusItem.button else {
            fatalError("someting awful has happend")
        }
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        popover.behavior = .transient
        popover.contentViewController = vc
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
}

extension StatusMenuController: graphPopDelegate {
    func getLastSevenDays() -> [Int] {
        return keyboardTracker.getXDaysData(X: 7)
    }
    
    func getCurrentKeyStroke() -> Int {
        return keyboardTracker.keyStrokeCount
    }
}


