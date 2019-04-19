//
//  GraphPopVC.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 4/19/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

protocol graphPopDelegate {
    func getLastSevenDays() -> [Int]
    
    func getCurrentKeyStroke() -> Int
}

class GraphPopVC: NSViewController {
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var averageKeyStrokes: NSTextField!
    @IBOutlet weak var maxKeyStrokes: NSTextField!
    @IBOutlet weak var dayOfWeekStack: NSStackView!
    @IBOutlet weak var currentKeyPresses: NSTextField!
    var graphPopDelegate: graphPopDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        graphView.graphPoints = graphPopDelegate?.getLastSevenDays() ?? [0,0,0,0,0,0,0]
        maxKeyStrokes.stringValue = "\(graphView.graphPoints.max() ?? 0)"
        averageKeyStrokes.stringValue = "\(Int(graphView.graphPoints.average))"
        
        let currentKeyStrokes:Int = (graphView.graphPoints.last ?? 0) + (graphPopDelegate?.getCurrentKeyStroke() ?? 0)
        currentKeyPresses.stringValue = "\(currentKeyStrokes)"
        
        let maxDayIndex = dayOfWeekStack.arrangedSubviews.count - 1
        
        // 4 - setup date formatter and calendar
        let today = Date()
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEE")
        
        for i in 0...maxDayIndex {
            if let date = calendar.date(byAdding: .day, value: -i, to: today),
                let label = dayOfWeekStack.arrangedSubviews[maxDayIndex - i] as? NSTextField {
                label.stringValue = formatter.string(from: date)
            }
        }
    }
    
    @IBAction func quitPressed(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}
