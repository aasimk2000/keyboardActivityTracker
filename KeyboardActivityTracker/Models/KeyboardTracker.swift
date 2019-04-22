//
//  KeyboardTracker.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import CoreData

class KeyboardTracker: NSObject {
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
        eventMonitor?.start()
    }
    
    
    func insertData() {
        let delegate = NSApp.delegate as? AppDelegate

        
        if let context = delegate?.persistentContainer.viewContext {
            let keypresses = NSEntityDescription.insertNewObject(forEntityName: "KeyPresses", into: context) as! KeyPresses
            keypresses.numKeyStrokes = Int16(keyStrokeCount)
            keypresses.startTime = firstEvent as NSDate?
            keypresses.endTime = lastEvent as NSDate?
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func fetchStatsArray() -> [KeyPresses] {
        var stats = [KeyPresses]()
        let delegate = NSApp.delegate as? AppDelegate
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "KeyPresses")
        if let context = delegate?.persistentContainer.viewContext {
            do {
                stats = try context.fetch(request) as! [KeyPresses]
            } catch {
                fatalError("Failure to read context: \(error)")
            }
        }
        
        return stats
    }
    
    func fetchData(predicate: NSPredicate) -> Int{
        let delegate = NSApp.delegate as? AppDelegate

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "KeyPresses")
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        var totalKeyStrokes = 0
        if let context = delegate?.persistentContainer.viewContext {
            do {
                let result = try context.fetch(request)
                for data in result as! [KeyPresses] {
                    totalKeyStrokes += Int(data.numKeyStrokes)
                }
            } catch {
                fatalError("Failure to read context: \(error)")
            }
        }
        
        return totalKeyStrokes
    }
    
    func createExportString() -> String {
        let fetchedStatsArray = fetchStatsArray()
        
        var export = "startTime, endTime, number of keystrokes\n"
        for (index, stat) in fetchedStatsArray.enumerated() {
            if index < fetchedStatsArray.count - 1 {
                let startString = "\(stat.startTime!)"
                let endString = "\(stat.endTime!)"
                let numKeyStrokes = stat.numKeyStrokes
                export += startString + "," + endString + ",\(numKeyStrokes)\n"
            }
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
