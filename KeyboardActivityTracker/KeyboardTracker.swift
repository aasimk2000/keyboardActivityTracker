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
                    self?.doSomething()
                    self?.keyStrokeCount = 0
                    self?.lastEvent = currentTime
                    self?.firstEvent = currentTime
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
    
    func printKeypresses() {
        print("Keypresses — \(keyStrokeCount)")
    }
    
    func doSomething() {
        print("Keystroke Ended")
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
        
        return totalKeyStrokes + keyStrokeCount
    }
}

