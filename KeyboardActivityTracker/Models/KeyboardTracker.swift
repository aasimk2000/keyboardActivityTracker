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
        eventMonitor = EventMonitor(mask: [.keyDown]) { [weak self] event in
            let currentTime = Date()
            if let time = self?.lastEvent {
                //print(currentTime.timeIntervalSince(time))
                if (Double(currentTime.timeIntervalSince(time)) > 15) {
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
        guard let delegate = NSApp.delegate as? AppDelegate else { return }
        
        let context = delegate.persistentContainer.viewContext
        let keypresses = KeyPresses(context: context)
        keypresses.numKeyStrokes = Int16(keyStrokeCount)
        keypresses.startTime = firstEvent as NSDate?
        keypresses.endTime = lastEvent as NSDate?
        delegate.saveAction(nil)
        os_log("End core data insertion", log: log, type: .info)
    }
    
    func fetchStatsArray() -> [KeyPresses] {
        var stats = [KeyPresses]()
        guard let delegate = NSApp.delegate as? AppDelegate else { return stats }
        
        let context = delegate.persistentContainer.viewContext
        do {
            stats = try context.fetch(KeyPresses.fetchRequest())
        } catch {
            fatalError("Failure to read context: \(error)")
        }
        
        return stats
    }
    
    func fetchData(predicate: NSPredicate) -> Int{
        guard let delegate = NSApp.delegate as? AppDelegate else { return 0 }

        let request: NSFetchRequest<KeyPresses> = KeyPresses.fetchRequest()
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        let context = delegate.persistentContainer.viewContext
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
    
    func getXDaysData(X past: Int) -> [Int]  {
        var data = [Int]()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        
        for i in (0..<past).reversed() {
            let timeBefore = TimeInterval(-1 * i * 24 * 60 * 60)
            let startDate = Date(timeInterval: timeBefore, since: Date())
            
            let dateFrom = calendar.startOfDay(for: startDate)
            let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
            
            let predicate = NSPredicate(format: "(startTime >= %@) AND (startTime < %@)", dateFrom as NSDate, dateTo! as NSDate);
            
            autoreleasepool {
                let daily = fetchData(predicate: predicate)
                data.append(daily)
            }
        }
        return data
    }
}
