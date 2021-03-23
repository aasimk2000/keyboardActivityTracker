//
//  GraphPopVC.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 4/19/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import Dispatch
import os.log

protocol graphPopDelegate: class {
    func getLastSevenDays() -> [Int]

    func getCurrentKeyStroke() -> Int

    var color: GraphColor { get set }
}

enum GraphColor: Int {
    case orange
    case blue
    case purple
    case kindablue

    var colors: (startColor: NSColor, endColor: NSColor) {
        switch self {
        case .orange:
            return (NSColor(calibratedRed: 250/255, green: 193/255, blue: 153/255, alpha: 1),
                    NSColor(calibratedRed: 252/255, green: 50/255, blue: 8/255, alpha: 1))
        case .blue:
            return (NSColor(calibratedRed: 94/255, green: 220/255, blue: 254/255, alpha: 1),
                    NSColor(calibratedRed: 102/255, green: 166/255, blue: 255/255, alpha: 1))
        case .purple:
            return (NSColor(calibratedRed: 102/255, green: 126/255, blue: 234/255, alpha: 1),
                    NSColor(calibratedRed: 118/255, green: 75/255, blue: 162/255, alpha: 1))
        case .kindablue:
            return (NSColor(calibratedRed: 48/255, green: 207/255, blue: 208/255, alpha: 1),
                    NSColor(calibratedRed: 51/255, green: 8/255, blue: 103/255, alpha: 1))

        }
    }
}

class GraphPopVC: NSViewController {

    @IBOutlet var graphView: GraphView!
    @IBOutlet var averageKeyStrokes: NSTextField!
    @IBOutlet var maxKeyStrokes: NSTextField!
    @IBOutlet var dayOfWeekStack: NSStackView!
    @IBOutlet var currentKeyPresses: NSTextField!
    @IBOutlet var colorPopUpButton: NSPopUpButton!

    let log = OSLog(subsystem: "KeyboardActivityTracker", category: "GraphPopVC")
    weak var graphPopDelegate: graphPopDelegate?
    var color: GraphColor {
        return AppDefaults.shared.graphColor
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        let graphPoints = self.graphPopDelegate?.getLastSevenDays()
        let average = graphPoints?.average ?? 0
        let max = graphPoints?.max() ?? 0
        let currentKeyStrokes = (graphPoints?.last ?? 0) + (self.graphPopDelegate?.getCurrentKeyStroke() ?? 0)
        self.colorPopUpButton.selectItem(at: color.rawValue)
        self.setGraph(color: color)
        self.graphView.graphPoints = graphPoints ?? [0, 0, 0, 0, 0, 0, 0]
        self.maxKeyStrokes.stringValue = "\(max)"
        self.averageKeyStrokes.stringValue = "\(Int(average))"
        self.currentKeyPresses.stringValue = "\(currentKeyStrokes)"

        zip(self.dayOfWeekStack.arrangedSubviews, GraphPopVC.getDaysOfWeek()).forEach { labelView, dayChar in
            if let label = labelView as? NSTextField {
                label.stringValue = String(dayChar)
            }
        }
    }

    func setGraph(color: GraphColor) {
        (graphView.startColor, graphView.endColor) = color.colors
    }

    @IBAction func quitPressed(_ sender: Any) {
        os_log("Quit pressed", log: log, type: .info)
        NSApplication.shared.terminate(self)
    }

    @IBAction func popUpPressed(_ sender: Any) {
        AppDefaults.shared.graphColor = GraphColor(rawValue: colorPopUpButton.indexOfSelectedItem) ?? GraphColor.orange
        setGraph(color: color)
    }

    /// Returns the Days of Week as a character array formatted as [\"M\", \"T\", \"W\", \"T\", \"F\", \"S\", \"S\"]
    /// Takes in a optional argument to specify when to start from, defaults to current day
    /// i.e. if startDay is a saturday [\"S\", \"M\", \"T\", \"W\", \"T\", \"F\", \"S\"] is returned
    static func getDaysOfWeek(startDay: Date = Date()) -> [Character] {
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEE")

        var components: [Character] = Array()

        let numberOfDays = 7

        for index in (0..<numberOfDays).reversed() {
            if let date = calendar.date(byAdding: .day, value: -index, to: startDay),
                let dateChar = formatter.string(from: date).first {
                components.append(dateChar)
            }
        }
        return components
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.makeKey()
        }
    }
}
