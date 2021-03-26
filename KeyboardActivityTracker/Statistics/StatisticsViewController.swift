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
    @IBOutlet weak var scrollView: NSScrollView!
    
    var currentTimeRange = StatisticsTimerange.week {
        didSet {
            if oldValue != currentTimeRange {
                loadData()
                statisticsView.needsDisplay = true
            }
        }
    }
    
    var data: [(Date, Int)]! {
        didSet {
            max = data.max { $0.1 < $1.1 }!.1
            min = data.min { $0.1 < $1.1 }!.1
        }
    }
    var max: Int = 0
    var min: Int = 0
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEE")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        statisticsView.dataSource = self
        // Do view setup here.
    }
    
    func loadData() {
        switch currentTimeRange {
        case .day:
            loadDayData()
        case .week:
            loadWeekData()
        case .month:
            loadMonthData()
        case .year:
            loadYearData()
        }
        if data.count > 0 {
            statisticsView.frame.size.width = CGFloat(32 * (data.count + 10))
        } else {
            statisticsView.frame.size.width = scrollView.contentSize.width
        }
    }
    
    func loadDayData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let hour = DateComponents(hour: 1)
        data = CoreDataStack.shared.getValues(groupedBy: .day, interval: hour)
    }
    
    func loadWeekData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let day = DateComponents(day: 1)
        data = CoreDataStack.shared.getValues(groupedBy: .weekOfYear, interval: day)
    }
    
    func loadMonthData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let day = DateComponents(day: 1)
        data = CoreDataStack.shared.getValues(groupedBy: .month, interval: day)
    }
    
    func loadYearData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let month = DateComponents(month: 1)
        data = CoreDataStack.shared.getValues(groupedBy: .year, interval: month)
    }
}

extension StatisticsViewController: StatisticsViewDataSource {
    func statisticsViewItemCount() -> Int {
        return data.count
    }
    
    func statisticsViewValue(for index: Int) -> CGFloat {
        
        return CGFloat(data[index].1)
    }
    
    func statisticsViewMaxValue() -> CGFloat {
        return CGFloat(max)
    }
    
    func statisticsViewMinValue() -> CGFloat {
        return CGFloat(min)
    }
    
    func statisticsViewLabel(for index: Int) -> String? {
        let day = data[index].0
        return dateFormatter.string(from: day)
    }
    
    func statisticsViewSeparate(at index: Int) -> Bool {
        return index == 1 || index == 4
    }
}
