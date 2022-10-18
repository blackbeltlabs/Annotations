import CoreGraphics

final class ArrowPathCreator: PathCreator {
  func createPath(for figure: Arrow) -> CGPath {
    let (origin, to) = (figure.origin.cgPoint, figure.to.cgPoint)
    let length = PathCalculations.distance(from: origin, to: to)
    
    return arrow(from: origin,
                 to: to,
                 tailWidth: 5 + CGFloat(length) / 45,
                 headWidth: 15 + CGFloat(length) / 15,
                 headLength: length >= 20 ? 20 + CGFloat(length) / 15 : CGFloat(length))
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
