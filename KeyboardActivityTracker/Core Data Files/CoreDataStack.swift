//
//  CoreDataStack.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/22/21.
//  Copyright © 2021 Aasim Kandrikar. All rights reserved.
//

import CoreData

class CoreDataStack {
    static var shared: CoreDataStack = .init()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KeyboardActivityTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        container.viewContext.undoManager = nil
        return container
    }()
    
    var taskContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func insertKeyPress(count: Int16, from: Date, to: Date) {
        let context = taskContext
        let keypresses = KeyPresses(context: context)
        keypresses.numKeyStrokes = Int16(count)
        keypresses.startTime = from as NSDate?
        keypresses.endTime = to as NSDate?
        do {
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    func getValues(from: Date, to: Date, interval: DateComponents) -> [(Date, Int)] {
        let context = taskContext
        let request: NSFetchRequest<KeyPresses> = KeyPresses.fetchRequest()
        let predicate = NSPredicate(format: "(startTime >= %@) AND (startTime < %@)", from as NSDate, to as NSDate)
        request.predicate = predicate
        request.propertiesToFetch = [#keyPath(KeyPresses.startTime), #keyPath(KeyPresses.numKeyStrokes)]
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(KeyPresses.startTime), ascending: true)]
        do {
            let results = try context.fetch(request)
            let calendar = Calendar.current
            var start = from
            var end = calendar.date(byAdding: interval, to: start)!
            var dict: [(Date,Int)] = []
            var index = results.startIndex
            while end <= to {
                var count = 0
                while index != results.endIndex {
                    if (results[index].startTime! as Date) < end {
                        count += Int(results[index].numKeyStrokes)
                        index = results.index(after: index)
                    } else {
                        break
                    }
                }
                dict.append((start, count))
                start = end
                end = calendar.date(byAdding: interval, to: start)!
            }
            return dict
        } catch {
            return []
        }
    }
}
