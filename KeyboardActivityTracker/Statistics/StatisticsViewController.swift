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
    
    var currentTimeRange = StatisticsTimerange.week {
        didSet {
            if oldValue != currentTimeRange {
                loadData()
                statisticsView.needsDisplay = true
            }
        }
    }
    
    let vals: [CGFloat] = [10, 20, 50, 100, 19, 200, 50]
    var data: [(Date, Int)]!
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
    }
    
    func loadDayData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        let start = calendar.date(byAdding: .day, value: -1, to: end)!
        var month = DateComponents()
        month.hour = 1
        data = CoreDataStack.shared.getValues(from: start, to: end, interval: month)
    }
    
    func loadWeekData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        let start = calendar.date(byAdding: .weekOfYear, value: -1, to: end)!
        var month = DateComponents()
        month.day = 1
        data = CoreDataStack.shared.getValues(from: start, to: end, interval: month)
        assert(data.count == 7)
    }
    
    func loadMonthData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        let start = calendar.date(byAdding: .month, value: -1, to: end)!
        var month = DateComponents()
        month.day = 1
        data = CoreDataStack.shared.getValues(from: start, to: end, interval: month)
    }
    
    func loadYearData() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        let start = calendar.date(byAdding: .year, value: -1, to: end)!
        var month = DateComponents()
        month.month = 1
        data = CoreDataStack.shared.getValues(from: start, to: end, interval: month)
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
        return CGFloat(data.max { $0.1 < $1.1 }!.1 )
    }
    
    func statisticsViewMinValue() -> CGFloat {
        return CGFloat(data.min { $0.1 < $1.1 }!.1 )
    }
    
    func statisticsViewLabel(for index: Int) -> String? {
        let day = data[index].0
        return dateFormatter.string(from: day)
    }
    
    func statisticsViewSeparate(at index: Int) -> Bool {
        return index == 1 || index == 4
    }
}
