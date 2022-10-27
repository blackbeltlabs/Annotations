import Foundation

class FigureStyleFactory {
  static func figureStyle(for figure: Figure) -> LayerUISettings? {
    switch figure {
    case let arrow as Arrow:
      return ArrowStyleCreator().createStyle(for: arrow)
    case let pen as Pen:
      return PenStyleCreator().createStyle(for: pen)
    case let rect as Rect:
      return RectStyleCreator().createStyle(for: rect)
    case let number as Number:
      return NumberStyleCreator().createStyle(for: number)
    default:
      return nil
    }
  }
}
