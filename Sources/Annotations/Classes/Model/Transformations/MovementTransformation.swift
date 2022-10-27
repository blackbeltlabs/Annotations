import Foundation

public final class MovementTransformation {
  public static func movedAnnotation(_ annotation: AnnotationModel, delta: CGVector) -> AnnotationModel {
    var updatedAnnotation = annotation
    updatedAnnotation.points = annotation.points.map { $0.applyingDelta(vector: delta) }
 
    return updatedAnnotation
  }
}
