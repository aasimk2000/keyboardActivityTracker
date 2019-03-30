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
    @IBOutlet weak var dailyKeyCountView: DailyKeyCountView!
    var keyStrokeMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let keyboardTracker = KeyboardTracker()
    @IBOutlet weak var activityView: KeyboardActivityView!
    var detailsWindow: DetailsViewController?
    
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
        keyboardTracker.statusMenuController = self
        keyboardTracker.monintorEvent()
        keyStrokeMenuItem = statusMenu.item(withTitle: "Key Strokes")
        keyStrokeMenuItem.view = dailyKeyCountView
        self.updateDetails()
        detailsWindow = DetailsViewController()
        detailsWindow?.delegate = self
        self.printKeyStrokes()
        activityView.loadBars()
    }
        
    @IBAction func detailsClicked(_ sender: Any) {
        detailsWindow?.showWindow(nil)
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

        self.dailyKeyCountView.update(daily: daily, total: keyboardTracker.fetchData(predicate: NSPredicate(value: true)))
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
}

