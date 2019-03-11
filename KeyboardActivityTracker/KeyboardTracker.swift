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
    var keyPresses = 0
    var firstEvent: Date?
    var lastEvent: Date?
    
    func monintorEvent() {
        eventMonitor = EventMonitor(mask: [.keyDown]) { [weak self] event in
            let currentTime = Date()
            if let time = self?.lastEvent {
                //print(currentTime.timeIntervalSince(time))
                if (Double(currentTime.timeIntervalSince(time)) > 15) {
                    self?.doSomething()
                    self?.keyPresses = 0
                    self?.lastEvent = currentTime
                    self?.firstEvent = currentTime
                } else {
                    self?.keyPresses += 1
                    self?.lastEvent = currentTime
                }
            } else {
                self?.keyPresses += 1
                self?.lastEvent = currentTime
                self?.firstEvent = currentTime
            }
        }
        eventMonitor?.start()
    }
    
    func printKeypresses() {
        print("Keypresses — \(keyPresses)")
    }
    
    func doSomething() {
        print("Keystroke Ended")
        let delegate = NSApp.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let keypresses = NSEntityDescription.insertNewObject(forEntityName: "KeyPresses", into: context) as! KeyPresses
            keypresses.numKeyStrokes = Int16(keyPresses)
            keypresses.startTime = firstEvent as NSDate?
            keypresses.endTime = lastEvent as NSDate?
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
}

