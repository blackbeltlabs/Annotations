import CoreGraphics

final class ArrowPathCreator: PathCreator {
  func createPath(for figure: Arrow) -> CGPath {
    let (origin, to) = (figure.origin.cgPoint, figure.to.cgPoint)
    let length = PathCalculations.distance(from: origin, to: to)
    
    let tailWidth = figure.lineWidth + CGFloat(length) / 45
    
    var headWidth = 15 + CGFloat(length) / 15
    
    // ensure correct arrow resizing when canvas is resizing
    let maxHeadWidthCoeff = 3.2
    if headWidth > tailWidth * maxHeadWidthCoeff {
      headWidth = tailWidth * maxHeadWidthCoeff
    }

    var headLength = length >= 20 ? 20 + CGFloat(length) / 15 : CGFloat(length)
    // ensure correct arrow resizing when canvas is resizing
    let diff = headLength / tailWidth
    let maxTailWidthCoeff = 4.0
    if diff > maxTailWidthCoeff {
      headLength = tailWidth * maxTailWidthCoeff
    }
    
    return arrow(from: origin,
                 to: to,
                 tailWidth: tailWidth,
                 headWidth: headWidth,
                 headLength: headLength)
  }
  
  private func arrow(from start: CGPoint,
                     to end: CGPoint,
                     tailWidth: CGFloat,
                     headWidth: CGFloat,
                     headLength: CGFloat) -> CGPath {
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
    
    return path
  }
}
