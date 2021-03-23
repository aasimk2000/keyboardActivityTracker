//
//  AppDefaults.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/23/21.
//  Copyright © 2021 Aasim Kandrikar. All rights reserved.
//

import AppKit

final class AppDefaults {
    static var shared = AppDefaults()
    private init() {}
    
    struct Key {
        static let graphColor = "color"
    }
    
    var graphColor: GraphColor {
        get {
            return GraphColor(rawValue: UserDefaults.standard.integer(forKey: Key.graphColor)) ?? .orange
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.graphColor)
        }
    }
}
