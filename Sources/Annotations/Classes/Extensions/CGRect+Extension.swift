import CoreGraphics

struct RectPoints {
  let leftTop: CGPoint
  let leftBottom: CGPoint
  let rightTop: CGPoint
  let rightBottom: CGPoint
}

extension CGRect {
  static func rect(fromPoint: CGPoint, toPoint: CGPoint) -> CGRect {
    let x = min(fromPoint.x, toPoint.x)
    let y = min(fromPoint.y, toPoint.y)
    let width = abs(toPoint.x - fromPoint.x)
    let height = abs(toPoint.y - fromPoint.y)
    
    return self.init(x: x, y: y, width: width, height:  height)
  }
  
  init(fromPoint: CGPoint, toPoint: CGPoint) {
      let x = min(fromPoint.x, toPoint.x)
      let y = min(fromPoint.y, toPoint.y)
      let width = abs(toPoint.x - fromPoint.x)
      let height = abs(toPoint.y - fromPoint.y)
      self.init(x: x, y: y, width: width, height: height)
  }
  
  var allPoints: RectPoints {
    return .init(leftTop: CGPoint(x: minX, y: minY),
                 leftBottom: CGPoint(x: minX, y: maxY),
                 rightTop: CGPoint(x: maxX, y: minY),
                 rightBottom: CGPoint(x: maxX, y: maxY))
  }
}
