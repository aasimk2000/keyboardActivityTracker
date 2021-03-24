//
//  AppDelegate.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import AppKit

// swiftlint:disable line_length
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, graphPopDelegate {
    func getLastSevenDays() -> [Int] {
        return keyboardTracker.getXDaysData(X: 7)
    }
    
    func getCurrentKeyStroke() -> Int {
        return keyboardTracker.keyStrokeCount
    }
    
    var color: GraphColor = .blue
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    lazy var keyboardTracker = KeyboardTracker()
    lazy var graphPopVC: GraphPopVC = {
        let vc = GraphPopVC(nibName: "GraphPopVC", bundle: nil)
        vc.graphPopDelegate = self
        return vc
    }()
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = graphPopVC
        return popover
    }()
    
    lazy var statisticsWindowController: NSWindowController = {
        let storyboard = NSStoryboard(name: "Statistics", bundle: nil)
        return storyboard.instantiateInitialController()! as! NSWindowController
    }()
    
    func setUpMenubar() {
        if let button = statusItem.button {
            button.title = "💩"
            button.target = self
            // statusItem.menu = statusMenu
        }
        statusItem.button?.action = #selector(buttonPressed)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if !DEBUG
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options)

            keyboardTracker.monintorEvent()
        #endif
        setUpMenubar()
        statisticsWindowController.showWindow(self)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        #if !DEBUG
        keyboardTracker.eventMonitor?.stop()
        #endif
    }

    @objc func buttonPressed(_ sender: Any?) {
        guard let button = statusItem.button else {
            fatalError("someting awful has happend")
        }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }

}
