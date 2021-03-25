//
//  StatitisticsWindowController.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/23/21.
//  Copyright © 2021 Aasim Kandrikar. All rights reserved.
//

import AppKit

enum StatisticsTimerange: Int {
    case day, week, month, year
}

final class StatisticsWindowController: NSWindowController {
    @IBAction func didSelectTimerange(_ sender: NSSegmentedControl) {
        guard let statisticsViewController = contentViewController as? StatisticsViewController else { exit(0) }
        guard let newTimeRange = StatisticsTimerange(rawValue: sender.selectedSegment ) else { exit(0) }
        statisticsViewController.currentTimeRange = newTimeRange
    }
}
