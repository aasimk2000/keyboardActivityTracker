//
//  EventMonitor.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import AppKit
import os.log

public class EventMonitor {
    let log = OSLog(subsystem: "KeyboardActivityTracker", category: "EventMonitor")
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        os_log("Adding global event monitor", log: log, type: .info)
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            os_log("Removing global event monitor", log: log, type: .info)
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
