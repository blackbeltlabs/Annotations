import Foundation

public class ResizeTransformationFactory {
  public static func resizedAnnotation(annotation: AnnotationModel, knob: KnobType, delta: CGVector) -> AnnotationModel {
    switch (annotation, knob) {
    case (let arrow as Arrow, let knob as ArrowKnobType):
      return ResizeArrowTransformation().resizedAnnotation(arrow, knobType: knob, delta: delta)
    case (let rect as Rect, let knob as RectKnobType):
      return ResizeRectTransformation().resizedAnnotation(rect, knobType: knob, delta: delta)
    case (let number as Number, let knob as RectKnobType):
      return ResizeNumberTransformation().resizedAnnotation(number, knobType: knob, delta: delta)
    case (let text as Text, let knob as TextKnobType):
      return ResizeTextTransformation().resizedAnnotation(text, knobType: knob, delta: delta)
    default:
      return annotation
    }
  }
  
  public static func resizingStarted(_ annotation: AnnotationModel, knob: KnobType, point: CGPoint) {
    switch (annotation, knob) {
    case (let rect as Rect, let knob as RectKnobType):
      return ResizeRectTransformation().resizingStarted(rect, knobType: knob, point: point)
    case (let number as Number, let knob as RectKnobType):
      return ResizeNumberTransformation().resizingStarted(number, knobType: knob, point: point)
    default:
      break
    }
  }
}
