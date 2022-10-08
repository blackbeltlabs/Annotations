import Foundation

class ResizeRectTransformation: ResizeTransformation {
  
  private static var originPoint: CGPoint?
  private static var oppositePoint: CGPoint?
  
  
  static func startResizingRectBased<T: RectBased>(_ annotation: T, knobType: RectKnobType, point: CGPoint) {
    let rect = CGRect(fromPoint: annotation.origin.cgPoint, toPoint: annotation.to.cgPoint)
    let allPoints = rect.allPoints
  
    Self.originPoint = Self.point(in: allPoints,
                                  for: knobType)
    Self.oppositePoint = Self.oppositePoint(in: allPoints, for: knobType)
  }
    
  static func resizedRectBased<T: RectBased>(_ rectBased: T,
                                             knobType: RectKnobType,
                                             delta: CGVector,
                                             keepSquare: Bool) -> T {
    guard let originPoint = Self.originPoint, let oppositePoint = Self.oppositePoint else { return rectBased }
    
    var updatedAnnotation = rectBased
    
    let deltaToUse: CGVector = {
      if keepSquare {
        let maxValue = min(abs(delta.dx), abs(delta.dy))
        return CGVector(dx: maxValue * sign(for: delta.dx),
                        dy: maxValue * sign(for: delta.dy))
      } else {
        return delta
      }
    }()
    
    let originWithDelta = originPoint.modelPoint.applyingDelta(vector: deltaToUse)
    
    updatedAnnotation.origin = originWithDelta
    updatedAnnotation.to = oppositePoint.modelPoint
    
    Self.originPoint = originWithDelta.cgPoint
    
    return updatedAnnotation
  }
  
  func resizedAnnotation(_ annotation: Rect, knobType: RectKnobType, delta: CGVector) -> Rect {
    Self.resizedRectBased(annotation, knobType: knobType, delta: delta, keepSquare: false)
  }
  
  func resizingStarted(_ annotation: Rect, knobType: RectKnobType, point: CGPoint) {
    Self.startResizingRectBased(annotation, knobType: knobType, point: point)
  }
  
  private static func point(in rectPoints: RectPoints, for knobType: RectKnobType) -> CGPoint {
    switch knobType {
    case .bottomLeft:
      return rectPoints.leftBottom
    case .bottomRight:
      return rectPoints.rightBottom
    case .topLeft:
      return rectPoints.leftTop
    case .topRight:
      return rectPoints.rightTop
    }
  }
  
  private static func oppositePoint(in rectPoints: RectPoints, for knobType: RectKnobType) -> CGPoint {
    switch knobType {
    case .bottomLeft:
      return rectPoints.rightTop
    case .bottomRight:
      return rectPoints.leftTop
    case .topLeft:
      return rectPoints.rightBottom
    case .topRight:
      return rectPoints.leftBottom
    }
  }
  
  
  private static func sign(for floatingValue: Double) -> Double {
    return floatingValue < 0 ? -1.0 : 1.0
  }
  
  // FIXME: - Remove if not used
  private func pointToRect(pointsArray: [CGPoint]) -> CGRect {
      var greatestXValue = pointsArray[0].x
      var greatestYValue = pointsArray[0].y
      var smallestXValue = pointsArray[0].x
      var smallestYValue = pointsArray[0].y
      for point in pointsArray {
          greatestXValue = max(greatestXValue, point.x);
          greatestYValue = max(greatestYValue, point.y);
          smallestXValue = min(smallestXValue, point.x);
          smallestYValue = min(smallestYValue, point.y);
      }
      let origin = CGPoint(x: smallestXValue, y: smallestYValue)
      let size = CGSize(width: greatestXValue - smallestXValue, height: greatestYValue - smallestYValue)
      return CGRect(origin: origin, size: size)
  }
}
