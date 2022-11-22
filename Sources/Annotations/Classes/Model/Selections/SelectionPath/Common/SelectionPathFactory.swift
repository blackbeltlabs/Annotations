import Foundation
import CoreGraphics

class SelectionPathFactory {
  static func selectionPath(for annotation: AnnotationModel) -> CGPath? {
    switch annotation {
    case let arrow as Arrow:
      return ArrowSelectionPathCreator().createSelectionPath(for: arrow)
    case let pen as Pen:
      return PenSelectionPathCreator().createSelectionPath(for: pen)
    case let rect as Rect:
      return RectSelectionPathCreator().createSelectionPath(for: rect)
    case let number as Number:
      return NumberSelectionPathCreator().createSelectionPath(for: number)
    case let text as Text:
      return TextSelectionPathCreator().createSelectionPath(for: text)
    default:
      return nil
    }
  }
}
