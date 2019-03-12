//
//  DailyKeyCountView.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

class DailyKeyCountView: NSView {

    @IBOutlet weak var totalKeyStrokes: NSTextField!
    @IBOutlet weak var dailyKeyStrokes: NSTextField!
    
    func update(daily: Int, total: Int) {
        DispatchQueue.main.async {
            self.dailyKeyStrokes.stringValue = "\(daily)"
            self.totalKeyStrokes.stringValue = "\(total)"
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
