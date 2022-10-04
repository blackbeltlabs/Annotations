import Foundation
import CoreGraphics

protocol MouseInteractionHandlerDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
  
  func update(model: AnnotationModel)
  func select(model: AnnotationModel)
  func deselect()
  
  var selectedAnnotation: AnnotationModel? { get }
}



class MouseInteractionHandler {
  
  public var lastDraggedPoint: CGPoint?
  
  private var annotationModified: Bool = false
  
  weak var dataSource: MouseInteractionHandlerDataSource?
  
  func handleMouseDown(point: CGPoint) {
   
    let annotations = dataSource!.annotations.sorted(by: { $0.zPosition > $1.zPosition })
    
    for annotation in annotations {
      let selectionPath = SelectionPathFactory.selectionPath(for: annotation)
      if let selectionPath, selectionPath.contains(point) {
        dataSource?.select(model: annotation)
        lastDraggedPoint = point
        return
      }
    }
    
    dataSource?.deselect()
    
    lastDraggedPoint = nil
  
    
    print("Need handle mouse down = \(point)")
  }
  
  func handleMouseDragged(point: CGPoint) {
    guard let lastDraggedPoint else { return }
    
    // move selected annotation if needed
    if let selectedAnnotation = dataSource?.selectedAnnotation {
      let updatedAnnotation = MovementTransformation.movedAnnotation(selectedAnnotation, delta: .init(dx: point.x - lastDraggedPoint.x, dy: point.y - lastDraggedPoint.y))
      dataSource?.select(model: updatedAnnotation)
      annotationModified = true
    }
    
    self.lastDraggedPoint  = point
    print("Need handle mouse dragged = \(point)")
  }
  
  
  func handleMouseUp(point: CGPoint) {
    
    if annotationModified, let selectedAnnotation = dataSource?.selectedAnnotation {
      dataSource?.update(model: selectedAnnotation)
    }
    
    lastDraggedPoint = nil
    annotationModified = false
  }
}
