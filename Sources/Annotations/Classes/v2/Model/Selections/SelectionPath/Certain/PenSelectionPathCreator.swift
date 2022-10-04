import CoreGraphics

final class PenSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for figure: Pen) -> CGPath {
    let path = PenPathCreator().createPath(for: figure)
    return path.copy(strokingWithWidth: 10.0,
                     lineCap: .butt,
                     lineJoin: .miter,
                     miterLimit: 1)
  }
}
