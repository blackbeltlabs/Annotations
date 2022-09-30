import Foundation

public final class Movement {
  public static func movedAnnotation(_ annotation: AnnotationModel, delta: CGVector) -> AnnotationModel {
    var updatedAnnotation = annotation
    updatedAnnotation.points = annotation.points.map({ annotationPoint in
      return AnnotationPoint(x: annotationPoint.x + delta.dx, y: annotationPoint.y + delta.dy)
    })
    return updatedAnnotation
  }
}
