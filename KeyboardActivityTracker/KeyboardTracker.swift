//
//  KeyboardTracker.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import CoreData
import os.log

class KeyboardTracker: NSObject {
    let log = OSLog(subsystem: "KeyboardActivityTracker", category: "KeyboardTracker")
    var eventMonitor: EventMonitor?
    var keyStrokeCount = 0
    var firstEvent: Date?
    var lastEvent: Date?

    func monintorEvent() {
        eventMonitor = EventMonitor(mask: [.keyDown]) { [weak self] _ in
            let currentTime = Date()
            if let time = self?.lastEvent {
                //print(currentTime.timeIntervalSince(time))
                if Double(currentTime.timeIntervalSince(time)) > 15 {
                    self?.insertData()
                    self?.keyStrokeCount = 0
                    self?.lastEvent = currentTime
                    self?.firstEvent = currentTime
//                    self?.statusMenuController?.printKeyStrokes()
                } else {
                    self?.keyStrokeCount += 1
                    self?.lastEvent = currentTime
                }
            } else {
                self?.keyStrokeCount += 1
                self?.lastEvent = currentTime
                self?.firstEvent = currentTime
            }
        }
        os_log("Started event monitor", log: log, type: .info)
        eventMonitor?.start()
    }

    func insertData() {
        os_log("Begin keypress insertion into core data", log: log, type: .info)
        CoreDataStack.shared.insertKeyPress(count: Int16(keyStrokeCount), from: firstEvent!, to: lastEvent!)
        os_log("End core data insertion", log: log, type: .info)
    }

    func fetchStatsArray() -> [KeyPresses] {
        var stats = [KeyPresses]()

        let context = CoreDataStack.shared.taskContext
        do {
            stats = try context.fetch(KeyPresses.fetchRequest())
        } catch {
            fatalError("Failure to read context: \(error)")
        }

        return stats
    }

    func fetchData(predicate: NSPredicate) -> Int {

        let request: NSFetchRequest<KeyPresses> = KeyPresses.fetchRequest()
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        let context = CoreDataStack.shared.taskContext
        do {
            let result = try context.fetch(request)
            return result.reduce(0) { $0 + Int($1.numKeyStrokes) }
        } catch {
            fatalError("Failure to read context: \(error)")
        }
    }

    func createExportString() -> String {
        let fetchedStatsArray = fetchStatsArray()

        var export = "startTime, endTime, number of keystrokes\n"
        for stat in fetchedStatsArray {
            let startString = "\(stat.startTime!)"
            let endString = "\(stat.endTime!)"
            let numKeyStrokes = stat.numKeyStrokes
            export += startString + "," + endString + ",\(numKeyStrokes)\n"
        }

        return export
    }

    func getXDaysData(X past: Int) -> [Int] {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        let start = calendar.date(byAdding: .day, value: -past, to: end)!
        var day = DateComponents()
        day.day = 1
        let dataDict = CoreDataStack.shared.getValues(from: start, to: end, interval: day)
        return dataDict.map { $0.1 }
    }
}
