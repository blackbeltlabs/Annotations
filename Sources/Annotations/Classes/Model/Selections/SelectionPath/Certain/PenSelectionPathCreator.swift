import CoreGraphics

final class PenSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Pen) -> CGPath {
    let path = PenPathCreator().createPath(for: annotation)
    return path.copy(strokingWithWidth: 10.0,
                     lineCap: .butt,
                     lineJoin: .miter,
                     miterLimit: 1)
  }
}
