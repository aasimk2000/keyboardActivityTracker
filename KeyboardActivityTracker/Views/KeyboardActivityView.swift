//
//  KeyboardActivityView.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import CoreGraphics

class KeyboardActivityView: NSView {
    var endArc:CGFloat = 0.0 {   // in range of 0.0 to 1.0
        didSet{
            needsDisplay = true
        }
    }
    var currentKeycount:Int? {
        didSet{
            computeEndArc()
        }
    }
    var totalKeycount:Int? {
        didSet{
            computeEndArc()
        }
    }
    
    var arcWidth:CGFloat = 35.0
    var arcColor = NSColor(calibratedRed: 235/255, green: 23/255, blue: 0, alpha: 1)
    var arcBackgroundColor = NSColor(calibratedRed: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    
    func computeEndArc() {
        endArc = CGFloat(Double((currentKeycount ?? 0))/Double(totalKeycount ?? 1))
    }
    
    override func draw(_ rect: NSRect) {
        //Important constants for circle
        let fullCircle = 2.0 * CGFloat.pi
        let start:CGFloat = -0.25 * (fullCircle)
        let end:CGFloat = endArc * fullCircle + start
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        var radius:CGFloat = 0.0
        if rect.width > rect.height {
            radius = (rect.width - arcWidth) / 2.0
        }else{
            radius = (rect.height - arcWidth) / 2.0
        }
        
        let context = NSGraphicsContext.current?.cgContext
        _ = CGColorSpaceCreateDeviceRGB()
        
        context?.setLineWidth(arcWidth)
        context?.setLineCap(.round)
        context?.setStrokeColor(arcBackgroundColor.cgColor)
        context?.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: fullCircle, clockwise: false)
        context?.strokePath()
        context?.setLineWidth(arcWidth * 0.8)
        context?.setStrokeColor(arcColor.cgColor)
        
        context?.addArc(center: centerPoint, radius: radius, startAngle: -start, endAngle: -end, clockwise: true)
        context?.strokePath()
    }
}


