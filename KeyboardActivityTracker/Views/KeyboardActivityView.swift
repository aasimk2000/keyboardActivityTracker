//
//  KeyboardActivityView.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/11/19.
//  Copyright © 2019 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import CoreGraphics

class KeyboardActivityView: OGCircularBarView {
    var totalKeycount: Int? {
        didSet {
            computeProgress()
            updateBars()
        }
    }
    var currentKeycount: Int? {
        didSet {
            computeProgress()
            updateBars()
        }
    }
    var progress = 0.0
    
    func computeProgress() {
        progress = Double(currentKeycount ?? 0) / Double(totalKeycount ?? 1)
    }
    
    func animateTheBars() {
        self.bars[0].animateProgress(CGFloat(progress), duration: 10)
    }
    
    func updateBars() {
        if let ring = self.bars.last {
            ring.animateProgress(CGFloat(progress), duration: 0)
        }
    }
    
     func loadBars() {
        //let pink = NSColor(calibratedRed: 1, green: 0.059, blue: 0.575, alpha: 1)
        let blue = NSColor(calibratedRed: 20/255, green: 160/255, blue: 255, alpha: 1)
        //let green = NSColor(calibratedRed: 0.321, green: 0.95, blue: 0.2, alpha: 1)
        
        // Normal Backgrounds
        
        //self.addBarBackground(startAngle: 90, endAngle: -270, radius: 100, width: 15, color: pink.withAlphaComponent(0.1))
        //self.addBarBackground(startAngle: 90, endAngle: -270, radius: 120, width: 15, color: blue.withAlphaComponent(0.1))
        self.addBarBackground(startAngle: 90, endAngle: -270, radius: 75, width: 10, color: blue.withAlphaComponent(0.1))
        
        // Normal Bars
        
        //self.addBar(startAngle: 90, endAngle: -270, progress: 0 , radius: 100, width: 15, color: pink, animationDuration: 0, glowOpacity: 0.4, glowRadius: 8)
        //self.addBar(startAngle: 90, endAngle: -270, progress: 0.45, radius: 120, width: 15, color: blue, animationDuration: 1.5, glowOpacity: 0.4, glowRadius: 8)
        self.addBar(startAngle: 90, endAngle: -270, progress: CGFloat(progress), radius: 75, width: 10, color: blue, animationDuration: 1.5, glowOpacity: 0.4, glowRadius: 3)
        
        // Half Bar Backgrounds
        
        //self.addBarBackground(startAngle: 175, endAngle: 5, radius: 150, width: 15, color: NSColor.magenta.withAlphaComponent(0.1))
        //self.addBarBackground(startAngle: -175, endAngle: -5, radius: 150, width: 15, color: NSColor.cyan.withAlphaComponent(0.1))
        
        // Half Bars
        //self.addBar(startAngle: 175, endAngle: 5, progress: 0.50, radius: 150, width: 15, color: NSColor.magenta.withAlphaComponent(0.6), animationDuration: 1.5, glowOpacity: 0.4, glowRadius: 8)
        //self.addBar(startAngle: -175, endAngle: -5, progress: 0.50, radius: 150, width: 15, color: NSColor.cyan.withAlphaComponent(0.6), animationDuration: 1.5, glowOpacity: 0.4, glowRadius: 8)
    }
}

public class OGCircularBarView: NSView, Sequence {
    
    public var bars: [CircularBarLayer] = []
    public var circleBars: [CircularBarLayer] = []
    var center: CGPoint {
        get {
            return NSMakePoint(floor(bounds.width/2), floor(bounds.height/2))
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        wantsLayer = true
    }
    
    public func addBar(startAngle: CGFloat, endAngle: CGFloat, progress: CGFloat, radius: CGFloat, width: CGFloat, color: NSColor, animationDuration: CGFloat, glowOpacity: Float, glowRadius: CGFloat) {
        let barLayer = CircularBarLayer(center: center, radius: radius, width: width, startAngle: startAngle, endAngle: endAngle, color: color)
        barLayer.shadowColor = color.cgColor
        barLayer.shadowRadius = glowRadius
        barLayer.shadowOpacity = glowOpacity
        barLayer.shadowOffset = NSSize.zero
        
        layer?.addSublayer(barLayer)
        bars.append(barLayer)
        if animationDuration > 0 {
            barLayer.animateProgress(progress, duration: animationDuration)
        } else {
            barLayer.progress = progress
        }
    }
    
    public func addBarBackground(startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat, width: CGFloat, color: NSColor) {
        let barLayer = CircularBarLayer(center: center, radius: radius, width: width, startAngle: startAngle, endAngle: endAngle, color: color)
        barLayer.progress = 1
        layer?.addSublayer(barLayer)
    }
    
    
    public subscript(index: Int) -> CircularBarLayer {
        return bars[index]
    }
    
    public func makeIterator() -> IndexingIterator<[CircularBarLayer]> {
        return bars.makeIterator()
    }
    
}

open class CircularBarLayer: CAShapeLayer, CALayerDelegate, CAAnimationDelegate {
    
    var completion: (() -> Void)?
    
    open var progress: CGFloat? {
        get {
            return strokeEnd
        }
        set {
            strokeEnd = (newValue ?? 0)
        }
    }
    
    public init(center: CGPoint, radius: CGFloat, width: CGFloat, startAngle: CGFloat, endAngle: CGFloat, color: NSColor) {
        super.init()
        let bezier = NSBezierPath()
        bezier.appendArc(withCenter: NSZeroPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: startAngle > endAngle)
        bezier.transform(using: AffineTransform(translationByX: center.x, byY: center.y))
        delegate = self as CALayerDelegate
        path = bezier.cgPath
        fillColor = NSColor.clear.cgColor
        strokeColor = color.cgColor
        lineWidth = width
        lineCap = .round
        strokeStart = 0
        strokeEnd = 0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    open func animateProgress(_ progress: CGFloat, duration: CGFloat, completion: (() -> Void)? = nil) {
        removeAllAnimations()
        let progress = progress
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = strokeEnd
        animation.toValue = progress
        animation.duration = CFTimeInterval(duration)
        animation.delegate = self as CAAnimationDelegate
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        strokeEnd = progress
        add(animation, forKey: "strokeEnd")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion?()
        }
    }
}

extension NSBezierPath {
    
    internal var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            }
        }
        return path
    }
    
}
