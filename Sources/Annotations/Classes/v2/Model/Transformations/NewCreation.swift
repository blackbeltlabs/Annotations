import Foundation

class NewCreation {
  static func updatedAnnotation(annotation: AnnotationModel, draggedPoint: CGPoint) -> AnnotationModel {
    if var twoPointsModel = annotation as? TwoPointsModel {
      twoPointsModel.to = draggedPoint.modelPoint
      return twoPointsModel
    } else if var pen = annotation as? Pen {
      pen.points.append(draggedPoint.modelPoint)
      return pen
    } else {
      return annotation
    }
  }
}
