import CoreGraphics

final class PenPathCreator: PathCreator {
  func createPath(for figure: Pen) -> CGPath {
    let points = figure.points.map { $0.cgPoint }
    
    return linePath(points: points)
  }

  private func linePath(points: [CGPoint]) -> CGPath {
    let path = CGMutablePath()
    for (index, point) in points.enumerated() {
        if index == 0 {
            path.move(to: point)
        } else {
            path.addLine(to: point)
        }
    }
    return path
  }
}
