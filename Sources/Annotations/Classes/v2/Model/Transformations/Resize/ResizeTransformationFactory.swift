import Foundation

public class ResizeTransformationFactory {
  public static func resizedAnnotation(annotation: AnnotationModel, knob: KnobType, delta: CGVector) -> AnnotationModel {
    switch (annotation, knob) {
    case (let arrow as Arrow, let knob as ArrowKnobType):
      return ResizeArrowTransformation().resizedAnnotation(arrow, knobType: knob, delta: delta)
    case (let rect as Rect, let knob as RectKnobType):
      return ResizeRectTransformation().resizedAnnotation(rect, knobType: knob, delta: delta)
    default:
      return annotation
    }
  }
}
