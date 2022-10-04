import Foundation

class SelectionPathFactory {
  static func selectionPath(for figure: AnnotationModel) -> CGPath? {
    switch figure {
    case let arrow as Arrow:
      return ArrowSelectionPathCreator().createSelectionPath(for: arrow)
    case let pen as Pen:
      return PenSelectionPathCreator().createSelectionPath(for: pen)
    case let rect as Rect:
      return RectSelectionPathCreator().createSelectionPath(for: rect)
    case let number as Number:
      return NumberSelectionPathCreator().createSelectionPath(for: number)
    default:
      return nil
    }
  }
}
