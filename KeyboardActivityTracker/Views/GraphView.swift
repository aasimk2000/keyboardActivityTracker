//
//  File.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/30/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa

@IBDesignable class GraphView: NSView {
    private struct Constants {
        static let cornerRadius: CGFloat = 8.0
        static let cornerRadiusSize = CGSize(width: cornerRadius, height: cornerRadius)
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    
    @IBInspectable var startColor = NSColor(calibratedRed: 250/255, green: 193/255, blue: 153/255, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    @IBInspectable var endColor: NSColor = NSColor(calibratedRed: 252/255, green: 50/255, blue: 8/255, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    var graphPoints = [1, 1, 1, 1, 0, 0] {
        didSet {
            needsDisplay = true
        }
    }
    
    override var isFlipped: Bool {
        get {
            return true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let width = dirtyRect.width
        let height = dirtyRect.height
        
        let path = NSBezierPath(roundedRect: dirtyRect,
                                xRadius: Constants.cornerRadius,
                                yRadius: Constants.cornerRadius)
        path.addClip()
        
        let context = NSGraphicsContext.current?.cgContext
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context?.drawLinearGradient(gradient,
                                    start: startPoint,
                                    end: endPoint,
                                    options: [])
        
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max() ?? 0 // Change this to not forcibly unwrap
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y
        }
        
        NSColor.white.setFill()
        NSColor.white.setStroke()
        
        let graphPath = NSBezierPath()
        graphPath.move(to: CGPoint(x: columnXPoint(0),
                                   y: columnYPoint(graphPoints.first ?? 0))) // Again change to not force unwrap
        
        for (i, j) in graphPoints[1...].enumerated() {
            let nextPoint = CGPoint(x: columnXPoint(i+1), y: columnYPoint(j))
            graphPath.line(to: nextPoint)
        }
        context?.saveGState()
        
        let clippingPath = graphPath.copy() as! NSBezierPath
        
        clippingPath.line(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.line(to: CGPoint(x: columnXPoint(0), y:height))
        clippingPath.close()
        
        clippingPath.addClip()
        
        
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
        
        context?.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context?.restoreGState()
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        for (i, j) in graphPoints.enumerated() {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(j))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = NSBezierPath(ovalIn: CGRect(origin: point,
                                                     size: CGSize(width: Constants.circleDiameter,
                                                                  height: Constants.circleDiameter)))
            circle.fill()
        }
        
        let linePath = NSBezierPath()
        
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.line(to: CGPoint(x: width - margin, y: topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBorder))
        linePath.line(to: CGPoint(x: width - margin, y: graphHeight / 2 + topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.line(to: CGPoint(x: width - margin, y: height - bottomBorder))
        let color = NSColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
    }
}
