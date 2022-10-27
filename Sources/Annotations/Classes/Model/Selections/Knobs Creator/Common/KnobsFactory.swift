import Foundation

class KnobsFactory {
  static func knobPair(for annotation: AnnotationModel) -> KnobPair? {
    switch annotation {
    case let arrow as Arrow:
      return ArrowKnobsCreator().createKnobs(for: arrow)
    case let rect as Rect:
      return RectKnobsCreator().createKnobs(for: rect)
    case let number as Number:
      return NumberKnobsCreator().createKnobs(for: number)
    case let text as Text:
      return TextKnobsCreator().createKnobs(for: text)
    default:
      return nil
    }
  }
}
