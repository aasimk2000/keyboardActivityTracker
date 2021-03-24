//
//  StatisticsViewController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/23/21.
//  Copyright © 2021 Aasim Kandrikar. All rights reserved.
//

import Cocoa

final class StatisticsViewController: NSViewController {
    @IBOutlet weak var statisticsView: StatisticsView!
    let vals: [CGFloat] = [10, 20, 50, 100, 19, 200, 50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticsView.dataSource = self
        // Do view setup here.
    }
    
}

extension StatisticsViewController: StatisticsViewDataSource {
    func statisticsViewItemCount() -> Int {
        return vals.count
    }
    
    func statisticsViewValue(for index: Int) -> CGFloat {
        
        return vals[index]
    }
    
    func statisticsViewMaxValue() -> CGFloat {
        return vals.max()!
    }
    
    func statisticsViewMinValue() -> CGFloat {
        return vals.min()!
    }
    
    func statisticsViewLabel(for index: Int) -> String {
        switch index {
        case 0:
            return "M"
        case 1:
            return "T"
        case 2:
            return "W"
        case 3:
            return "T"
        case 4:
            return "F"
        case 5:
            return "S"
        case 6:
            return "S"
        default:
            return "A"
        }
    }
    
    func statisticsViewSeparate(at index: Int) -> Bool {
        return index == 1 || index == 4
    }
    
    
}
