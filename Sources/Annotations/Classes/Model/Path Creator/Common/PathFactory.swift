import Foundation
import CoreGraphics

class PathFactory {
  static func path(for figure: Figure) -> CGPath? {
    switch figure {
    case let arrow as Arrow:
      return ArrowPathCreator().createPath(for: arrow)
    case let pen as Pen:
      return PenPathCreator().createPath(for: pen)
    case let rect as Rect:
      return RectPathCreator().createPath(for: rect)
    case let number as Number:
      return NumberPathCreator().createPath(for: number)
    default:
      return nil
    }
  }
}
