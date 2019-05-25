//
//  GraphPopVCTests.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 5/25/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import XCTest
@testable import KeyboardActivityTracker

class GraphPopVCTests: XCTestCase {
    func testGetDaysOfWeek() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tuesday = Date(timeIntervalSinceReferenceDate: 86400) //Tuesday, January 2, 2001
        let tueWeek = GraphPopVC.getDaysOfWeek(startDay: tuesday)
        XCTAssert(tueWeek == ["W", "T", "F", "S", "S", "M", "T"])
        
        let wednesday = Date(timeInterval: 24 * 60 * 60, since: tuesday) // Wed
        let wedWeek = GraphPopVC.getDaysOfWeek(startDay: wednesday)
        XCTAssert(wedWeek == ["T", "F", "S", "S", "M", "T", "W"])
    }
}
