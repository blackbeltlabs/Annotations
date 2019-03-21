//
//  NSBezierPathExtension.swift
//  Annotate
//
//  Created by Mirko on 12/26/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa

extension NSBezierPath {
  convenience init(path: CGPath) {
    self.init()
    let pathPtr = UnsafeMutablePointer<NSBezierPath>.allocate(capacity: 1)
    pathPtr.initialize(to: self)
    
    path.applyWithBlock { (elementPtr) in
      let element = elementPtr.pointee
      
      let pointsPtr = element.points
      
      switch element.type {
      case .moveToPoint:
        self.move(to: pointsPtr.pointee)
        
      case .addLineToPoint:
        self.line(to: pointsPtr.pointee)
        
      case .addQuadCurveToPoint:
        let firstPoint = pointsPtr.pointee
        let secondPoint = pointsPtr.successor().pointee
        
        let currentPoint = path.currentPoint
        let x = (currentPoint.x + 2 * firstPoint.x) / 3
        let y = (currentPoint.y + 2 * firstPoint.y) / 3
        let interpolatedPoint = CGPoint(x: x, y: y)
        
        let endPoint = secondPoint
        
        self.curve(to: endPoint, controlPoint1: interpolatedPoint, controlPoint2: interpolatedPoint)
        
      case .addCurveToPoint:
        let firstPoint = pointsPtr.pointee
        let secondPoint = pointsPtr.successor().pointee
        let thirdPoint = pointsPtr.successor().successor().pointee
        
        self.curve(to: thirdPoint, controlPoint1: firstPoint, controlPoint2: secondPoint)
        
      case .closeSubpath:
        self.close()
      }
      
      pointsPtr.deinitialize()
    }
  }
  
  static func line(points: [CGPoint]) -> NSBezierPath {
    let path = CGMutablePath()
    for (index, point) in points.enumerated() {
      if index == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
      }
    }
    let bezierPath = NSBezierPath(path: path)
    return bezierPath
  }
  
  class func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> NSBezierPath {
    let length = hypot(end.x - start.x, end.y - start.y)
    let tailLength = length - headLength
    
    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
    let points: [CGPoint] = [
      p(0, tailWidth / 2),
      p(tailLength, tailWidth / 2),
      p(tailLength, headWidth / 2),
      p(length, 0),
      p(tailLength, -headWidth / 2),
      p(tailLength, -tailWidth / 2),
      p(0, -tailWidth / 2)
    ]
    
    let cosine = (end.x - start.x) / length
    let sine = (end.y - start.y) / length
    let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
    
    let path = CGMutablePath()
    path.addLines(between: points, transform: transform)
    path.closeSubpath()
    
    return NSBezierPath(path: path)
  }
}

extension NSBezierPath {
  public var cgPath: CGPath {
    let path = CGMutablePath()
    var points = [CGPoint](repeating: .zero, count: 3)
    
    for i in 0 ..< self.elementCount {
      let type = self.element(at: i, associatedPoints: &points)
      switch type {
      case .moveTo:
        path.move(to: points[0])
      case .lineTo:
        path.addLine(to: points[0])
      case .curveTo:
        path.addCurve(to: points[2], control1: points[0], control2: points[1])
      case .closePath:
        path.closeSubpath()
      }
    }
    return path
  }
}

extension NSRect {
  init(fromPoint: CGPoint, toPoint: CGPoint) {
    let x = min(fromPoint.x, toPoint.x)
    let y = min(fromPoint.y, toPoint.y)
    let width = abs(toPoint.x - fromPoint.x)
    let height = abs(toPoint.y - fromPoint.y)
    self.init(x: x, y: y, width: width, height: height)
  }
  
  init(fromPoint: CGPoint, toPoint: CGPoint, size: CGSize) {
    let x = min(fromPoint.x, toPoint.x)
    let y = min(fromPoint.y, toPoint.y)
    self.init(origin: CGPoint(x: x, y: y), size: size)
  }
}

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
  return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
  return sqrt(CGPointDistanceSquared(from: from, to: to))
}


extension CGPath {
  func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
    typealias Body = @convention(block) (CGPathElement) -> Void
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
      let body = unsafeBitCast(info, to: Body.self)
      body(element.pointee)
    }
    //print(MemoryLayout.size(ofValue: body))
    let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
    self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
  }
  
  func points() -> [CGPoint] {
    var arrayPoints = [CGPoint]()
    self.forEach { element in
      switch (element.type) {
      case CGPathElementType.moveToPoint:
        arrayPoints.append(element.points[0])
      case .addLineToPoint:
        arrayPoints.append(element.points[0])
      case .addQuadCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
      case .addCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
        arrayPoints.append(element.points[2])
      default: break
      }
    }
    
    return arrayPoints
  }
}

