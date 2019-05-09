//
//  GraphPopVC.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 4/19/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import Dispatch

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
    weak var statusMenuController: StatusMenuController? = nil
    weak var graphPopDelegate: graphPopDelegate? = nil
    var color: GraphColor = .orange

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // print(color)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let graphPoints = self.graphPopDelegate?.getLastSevenDays()
            let average = graphPoints?.average ?? 0
            let max = graphPoints?.max() ?? 0
            let currentKeyStrokes = (graphPoints?.last ?? 0) + (self.graphPopDelegate?.getCurrentKeyStroke() ?? 0)
            
            let maxDayIndex = self.dayOfWeekStack.arrangedSubviews.count - 1
            
            // 4 - setup date formatter and calendar
            let today = Date()
            let calendar = Calendar.current
            
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEEE")
            
            let color = self.graphPopDelegate?.color ?? .orange

            DispatchQueue.main.async { [weak self] in
                self?.colorPopUpButton.selectItem(at: color.rawValue)
                self?.setGraph(color: color)
                self?.graphView.graphPoints = graphPoints ?? [0,0,0,0,0,0,0]
                self?.maxKeyStrokes.stringValue = "\(max)"
                self?.averageKeyStrokes.stringValue = "\(Int(average))"
                self?.currentKeyPresses.stringValue = "\(currentKeyStrokes)"
                
                for i in 0...maxDayIndex {
                    if let date = calendar.date(byAdding: .day, value: -i, to: today),
                        let label = self?.dayOfWeekStack.arrangedSubviews[maxDayIndex - i] as? NSTextField {
                        label.stringValue = formatter.string(from: date)
                    }
                }
            }
        }
    }
    
    func setGraph(color : GraphColor) {
        (graphView.startColor, graphView.endColor) = color.colors
    }
    
    @IBAction func quitPressed(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func popUpPressed(_ sender: Any) {
        graphPopDelegate?.color = GraphColor(rawValue: colorPopUpButton.indexOfSelectedItem) ?? GraphColor.orange
//        print(color)
        setGraph(color: graphPopDelegate?.color ?? .orange)
        let defaults = UserDefaults.standard
        defaults.setValue(graphPopDelegate?.color.rawValue ?? 0, forKey: "color")        
    }
}
