//
//  StatusMenuController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var dailyKeyCountView: DailyKeyCountView!
    @IBOutlet weak var activityView: KeyboardActivityView!
    
    var keyStrokeMenuItem: NSMenuItem!
    var detailsWindow: DetailsViewController?
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let keyboardTracker = KeyboardTracker()
    
    override func awakeFromNib() {
        setUpStatusItem()
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access not Enabled")
        }
        keyboardTracker.monintorEvent()
        self.updateDetails()
        self.printKeyStrokes()
        activityView.loadBars()
    }
    
    func setUpStatusItem() {
        if let button = statusItem.button {
            button.title = "💩"
            statusItem.menu = statusMenu
        }
    }
    
    func setUpDelegates() {
        keyboardTracker.statusMenuController = self
        statusMenu.delegate = self
        detailsWindow = DetailsViewController()
        detailsWindow?.delegate = self
        keyStrokeMenuItem.view = dailyKeyCountView
        keyStrokeMenuItem = statusMenu.item(withTitle: "Key Strokes")
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        printKeyStrokes()
    }
    
    @IBAction func detailsClicked(_ sender: Any) {
        detailsWindow?.showWindow(nil)
        detailsWindow?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        detailsWindow?.updateGraph()
    }
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func updateDetails() {
        let defaults = UserDefaults.standard
        let target = defaults.integer(forKey: "target")
        activityView.totalKeycount = target
    }
    
    func printKeyStrokes() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        let predicate = NSPredicate(format: "(startTime >= %@) AND (startTime < %@)", dateFrom as NSDate, dateTo! as NSDate);
        
        let daily = keyboardTracker.fetchData(predicate: predicate)
        activityView.currentKeycount = daily
        let current = keyboardTracker.keyStrokeCount

        self.dailyKeyCountView.update(daily: daily+current, total: keyboardTracker.fetchData(predicate: NSPredicate(value: true)) + current)
    }
    
    
}

extension StatusMenuController: DetailsWindowDelegate {
    func exportString() -> String {
        return keyboardTracker.createExportString()
    }

    func detailsDidUpdate() {
        updateDetails()
    }
    
    func getCurrentTarget() -> Int {
        return activityView.totalKeycount ?? 2000
    }
    
    func getLastSevenDays() -> [Int] {
        return keyboardTracker.getXDaysData(X: 7)
    }
}

