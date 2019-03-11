//
//  KeyPresses+CoreDataProperties.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//
//

import Foundation
import CoreData


extension KeyPresses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyPresses> {
        return NSFetchRequest<KeyPresses>(entityName: "KeyPresses")
    }

    @NSManaged public var numKeyStrokes: Int16
    @NSManaged public var startTime: NSDate?
    @NSManaged public var endTime: NSDate?

}
