import Foundation

class ResizeRectTransformation: ResizeTransformation {
  
  static func resizedRectBased<T: RectBased>(_ rectBased: T, knobType: RectKnobType, delta: CGVector) -> T {
    let rect = CGRect(fromPoint: rectBased.origin.cgPoint, toPoint: rectBased.to.cgPoint)
    let allPoints = rect.allPoints
    
    var updatedAnnotation = rectBased
      
    updatedAnnotation.origin = point(in: allPoints, for: knobType).modelPoint.applyingDelta(vector: delta)
    updatedAnnotation.to = oppositePoint(in: allPoints, for: knobType).modelPoint
    
    return updatedAnnotation
  }
  
  func resizedAnnotation(_ annotation: Rect, knobType: RectKnobType, delta: CGVector) -> Rect {
    Self.resizedRectBased(annotation, knobType: knobType, delta: delta)
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
