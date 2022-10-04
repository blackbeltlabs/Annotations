import Foundation
import CoreGraphics

protocol MouseInteractionHandlerDataSource: AnyObject {
  
  var annotations: [AnnotationModel] { get }

  
  func select(model: AnnotationModel)
  func deselect()
  
  var selectedAnnotation: AnnotationModel? { get }
}

class MouseInteractionHandler {
  
  weak var dataSource: MouseInteractionHandlerDataSource?
  
  
  
  func handleMouseDown(point: CGPoint) {
    let annotations = dataSource!.annotations.sorted(by: { $0.zPosition > $1.zPosition })
    
    
    for annotation in annotations {
      let selectionPath = SelectionPathFactory.selectionPath(for: annotation)
      if let selectionPath, selectionPath.contains(point) {
        dataSource?.select(model: annotation)
        return
      }
    }
    
    dataSource?.deselect()
    
    
    print("Need handle mouse down = \(point)")
  }
  
  func handleMouseDragged(point: CGPoint) {
    print("Need handle mouse dragged = \(point)")
  }
  
  
  func handleMouseUp(point: CGPoint) {
    print("Need handle mouse up = \(point)")
  }
}
