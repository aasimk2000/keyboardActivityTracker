//
//  StatisticsView.swift
//  KeyboardActivityTracker
//
//  Created by Aasim Kandrikar on 3/23/21.
//  Copyright © 2021 Aasim Kandrikar. All rights reserved.
//

import Cocoa
import CoreGraphics

protocol StatisticsViewDataSource: NSObject {
    func statisticsViewItemCount() -> Int
    func statisticsViewValue(for index: Int) -> CGFloat
    func statisticsViewMaxValue() -> CGFloat
    func statisticsViewMinValue() -> CGFloat
    func statisticsViewLabel(for index: Int) -> String?
    func statisticsViewSeparate(at index: Int) -> Bool
}

class StatisticsView: NSView {
    weak var dataSource: StatisticsViewDataSource!
    
    func computeGradient() -> CGGradient {
        let colors = [backgroundStartColor.cgColor, backgroundEndColor.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient =  CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
        return gradient!
    }
    
    var backgroundStartColor = NSColor(calibratedRed: 250/255, green: 193/255, blue: 153/255, alpha: 1)
    var backgroundEndColor = NSColor(calibratedRed: 252/255, green: 50/255, blue: 8/255, alpha: 1) {
        didSet {
            backgroundGradient = computeGradient()
        }
    }
    
    lazy var backgroundGradient: CGGradient = computeGradient()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        let roundRectPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 16.0, yRadius: 16.0)
        roundRectPath.addClip()
        drawBackgroundGradient(dirtyRect)
//        let dirtyRect = dirtyRect.insetBy(dx: 10, dy: 0)
        let graphBounds = graphRect(dirtyRect)
        drawHorizontalGrid(in: graphBounds)
        drawKeyStrokeCounts(in: graphBounds)
        let labelBounds = labelRect(dirtyRect)
        drawLabelText(in: labelBounds)
    }
    
    func drawBackgroundGradient(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let startPoint = CGPoint(x: 0, y: dirtyRect.height)
        let endPoint = CGPoint(x: 0, y: 0)
        ctx.drawLinearGradient(backgroundGradient, start: startPoint, end: endPoint, options: [])
    }
    
    func drawKeyStrokeCounts(in rect: NSRect) {
        NSColor.white.setStroke()
        let (path, _) = pathFromData(in: rect)
        path.stroke()
    }
    
    func drawLabelText(in rect: NSRect) {
        let itemCount = dataSource.statisticsViewItemCount()
        let font = NSFont.boldSystemFont(ofSize: 16)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraphStyle]
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.saveGState()
        let dataSpacing = (rect.width / CGFloat(itemCount - 1)).rounded(.down)
        print(dataSpacing)
        for i in 0..<itemCount {
            if let labelText = dataSource.statisticsViewLabel(for: i) as NSString? {
                // Have minX to datasapcing to draw Label
                let labelBounds = CGRect(x: rect.minX, y: rect.minY, width: dataSpacing, height: rect.height)
                labelText.draw(in: labelBounds, withAttributes: attributes)
            }
            ctx.translateBy(x: dataSpacing, y: 0)
        }
        ctx.restoreGState()
    }
    
    func drawHorizontalGrid(in rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let path = NSBezierPath()
        path.lineWidth = 1.0
        path.move(to: NSPoint(x: rect.minX.rounded(), y: rect.maxY.rounded() + 0.5))
        path.line(to: NSPoint(x: rect.maxX.rounded(), y: rect.maxY.rounded() + 0.5))
        let dashPattern: [CGFloat] = [1.0, 1.0]
        path.setLineDash(dashPattern, count: 2, phase: 0.0)
        let gridColor = NSColor(red: 74 / 255, green: 86/255, blue: 126/255, alpha: 1.0)
        ctx.saveGState()
        gridColor.setStroke()
        path.stroke()
        let topClip = topClipPath(in: rect)
        topClip.addClip()
        gridColor.setStroke()
        for _ in 1...5 {
            ctx.translateBy(x: 0, y: -((rect.height) / 5).rounded())
            path.stroke()
        }
        ctx.restoreGState()
    }
    
    func bottomClipPath(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let (dataPath, initialPoint) = pathFromData(in: rect)
        path.append(dataPath)
        let currentPoint = path.currentPoint
        path.line(to: CGPoint(x: rect.maxX, y: currentPoint.y))
        path.line(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.line(to: CGPoint(x: rect.minX, y: rect.minY))
        path.line(to: CGPoint(x: rect.minX, y: initialPoint.y))
        path.line(to: initialPoint)
        path.close()
        return path
    }
    
    func topClipPath(in rect: NSRect) -> NSBezierPath {
        let path = NSBezierPath()
        let (dataPath, initialPoint) = pathFromData(in: rect)
        path.append(dataPath)
        let currentPoint = path.currentPoint
        path.line(to: CGPoint(x: rect.maxX, y: currentPoint.y))
        path.line(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.line(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.line(to: CGPoint(x: rect.minX, y: initialPoint.y))
        path.line(to: initialPoint)
        path.close()
        return path
    }
    
    func pathFromData(in rect: NSRect) -> (NSBezierPath, CGPoint) {
        // TODO: max and min = 0
        let dataCounts = dataSource.statisticsViewItemCount()
        let maxCount = dataSource.statisticsViewMaxValue()
        let minCount = dataSource.statisticsViewMinValue()
        
        let path = NSBezierPath()
        let lineWidth: CGFloat = 5.0
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        let rect = rect.insetBy(dx: lineWidth / 2, dy: lineWidth)
        let horizontalSpacing = rect.width / CGFloat(dataCounts - 1)
        print(horizontalSpacing)
        let verticalScale = rect.height / (maxCount - minCount)
        var currentKeyCount = dataSource.statisticsViewValue(for: 0)
        let initialPoint = CGPoint(x: rect.minX, y: rect.minY + (currentKeyCount - minCount) * verticalScale)
        path.move(to: initialPoint)
        for i in 1..<(dataCounts - 1) {
            currentKeyCount = dataSource.statisticsViewValue(for: i)
            let x = rect.minX + (CGFloat(i) * horizontalSpacing)
            let y = rect.minY + ((currentKeyCount - minCount) * verticalScale)
            path.line(to: CGPoint(x: x, y: y))
        }
        currentKeyCount = dataSource.statisticsViewValue(for: dataCounts - 1)
        let y = rect.minY + (currentKeyCount - minCount) * verticalScale
        path.line(to: CGPoint(x: rect.origin.x + rect.width, y: y))
        return (path, initialPoint)
    }
    
    func strokeRect(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.saveGState()
        ctx.setStrokeColor(.black)
        ctx.setLineWidth(2.0)
        ctx.stroke(rect)
        ctx.restoreGState()
    }
    
    func graphRect(_ rect: NSRect) -> NSRect {
        let bottom: CGFloat = rect.origin.y + bottomLabelHeight(rect)
        let topPadding: CGFloat = 10
        let height = rect.height - bottomLabelHeight(rect) - topPadding
        let left: CGFloat = rect.origin.x
        let right = rect.width - rightLabelWidth(rect)
        return NSRect(x: left, y: bottom, width: right, height: height)
    }
    
    func labelRect(_ rect: NSRect) -> NSRect {
        let bottom = rect.origin.y
        let left = rect.origin.x
        let width = rect.width - rightLabelWidth(rect)
        let height = bottomLabelHeight(rect)
        return NSRect(x: left, y: bottom, width: width, height: height)
    }
    
    func bottomLabelHeight(_ rect: NSRect) -> CGFloat {
        return 30
    }
    
    func rightLabelWidth(_ rect: NSRect) -> CGFloat {
        // TODO: Fix this to be better
        return 40
    }
}
