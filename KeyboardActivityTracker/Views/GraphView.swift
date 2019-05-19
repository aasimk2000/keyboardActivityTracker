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
    
    @IBInspectable var startColor: NSColor = NSColor(calibratedRed: 250/255, green: 193/255, blue: 153/255, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    @IBInspectable var endColor: NSColor = NSColor(calibratedRed: 252/255, green: 50/255, blue: 8/255, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }
    var graphPoints: [Int] {
        didSet {
            needsDisplay = true
        }
    }
    
    override var isFlipped: Bool {
        get {
            return true
        }
    }
    
    override var wantsUpdateLayer: Bool {
        get {
            return true
        }
    }
    
    let graphLayer = CAShapeLayer()
    let gridLinesLayer = CAShapeLayer()
    let circlesLayer = CALayer()
    let gradientLayer = CAGradientLayer()
    
    var width: CGFloat { return frame.width }
    var height: CGFloat { return frame.height }
    
    var margin: CGFloat { return Constants.margin }
    var graphWidth: CGFloat { return width - margin * 2 - 4 }
    var topBorder: CGFloat { return Constants.topBorder }
    var bottomBorder: CGFloat { return Constants.bottomBorder }
    var graphHeight: CGFloat { return height - topBorder - bottomBorder }
    var maxValue: Int { return graphPoints.max() ?? 0 }
    
    
    private func configureView() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    init(frame frameRect: NSRect, points: [Int]) {
        graphPoints = points
        super.init(frame: frameRect)
        configureView()
        gradientLayer.frame = frameRect
        setupLayers()
    }
    
    func setupLayers() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.cornerRadius = Constants.cornerRadius
        gradientLayer.masksToBounds = true
        layer?.addSublayer(gradientLayer)
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = self.graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + self.margin + 2
        }
        
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(self.maxValue) * self.graphHeight
            return self.graphHeight + self.topBorder - y
        }
        
        let graphPath = CGMutablePath()
        graphPath.move(to: CGPoint(x: columnXPoint(0),
                                   y: columnYPoint(graphPoints.first ?? 0)))
        
        for (i, j) in graphPoints[1...].enumerated() {
            let nextPoint = CGPoint(x: columnXPoint(i+1), y: columnYPoint(j))
            graphPath.addLine(to: nextPoint)
        }
        
        graphLayer.path = graphPath
        graphLayer.lineWidth = 2
        graphLayer.strokeColor = NSColor.white.cgColor
        graphLayer.fillColor = .clear
        graphLayer.lineCap = .round
        
        for (i, j) in graphPoints.enumerated() {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(j))
            let circleLayer = CAShapeLayer()
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = CGPath(ellipseIn: CGRect(origin: point,
                                                  size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)), transform: nil)
            circleLayer.path = circle
            circleLayer.fillColor = NSColor.white.cgColor
            circleLayer.strokeColor = NSColor.white.cgColor
            circleLayer.lineWidth = 0.8
            circlesLayer.addSublayer(circleLayer)
        }
        
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight / 2 + topBorder))
        
        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: height - bottomBorder))
        gridLinesLayer.path = linePath
        gridLinesLayer.lineWidth = 1.0
        let color = NSColor(white: 1.0, alpha: Constants.colorAlpha)
        gridLinesLayer.strokeColor = color.cgColor
        
        gradientLayer.addSublayer(graphLayer)
        gradientLayer.addSublayer(gridLinesLayer)
        gradientLayer.addSublayer(circlesLayer)
    }
    
    override func updateLayer() {
        super.updateLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = self.graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + self.margin + 2
        }
        
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(self.maxValue) * self.graphHeight
            return self.graphHeight + self.topBorder - y
        }

        let graphPath = CGMutablePath()
        graphPath.move(to: CGPoint(x: columnXPoint(0),
                                   y: columnYPoint(graphPoints.first ?? 0)))
        
        for (i, j) in graphPoints[1...].enumerated() {
            let nextPoint = CGPoint(x: columnXPoint(i+1), y: columnYPoint(j))
            graphPath.addLine(to: nextPoint)
        }
        
        graphLayer.path = graphPath
        
        //        let highestYPoint = columnYPoint(maxValue)
        //        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        //        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
        
        circlesLayer.sublayers = nil
        
        for (i, j) in graphPoints.enumerated() {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(j))
            let circleLayer = CAShapeLayer()
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = CGPath(ellipseIn: CGRect(origin: point,
                                                  size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)), transform: nil)
            circleLayer.path = circle
            circleLayer.fillColor = NSColor.white.cgColor
            circleLayer.strokeColor = NSColor.white.cgColor
            circleLayer.lineWidth = 0.8
            circlesLayer.addSublayer(circleLayer)
        }
    }
    
    override convenience init(frame frameRect: NSRect) {
        self.init(frame: frameRect, points: [1, 2, 3, 4, 5, 6, 7])
    }
    
    required init?(coder decoder: NSCoder) {
        graphPoints = [1, 2, 3, 4, 5, 6, 7]
        super.init(coder: decoder)
        configureView()
        gradientLayer.frame = bounds
        setupLayers()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayers()
    }
}
