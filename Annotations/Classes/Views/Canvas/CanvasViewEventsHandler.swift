import Foundation

class CanvasViewEventsHandler {
    weak var canvasView: CanvasView?
    
    func mouseDown(with event: NSEvent) {
      guard let canvasView = self.canvasView else { return }
      
      guard canvasView.isUserInteractionEnabled else { return }
        
      let location = canvasView.convert(event.locationInWindow, from: nil)
      
      let point = location.pointModel
      
      canvasView.lastDraggedPoint = point
      

      switch canvasView.createMode {
      case .text:
        // specific case for text
        // texts should be created from single mouse press
        if !canvasItemSelected {
          if let newItem = canvasView.createItem(mouseDown: point,
                                                 color: canvasView.createColor) {
            canvasView.add(newItem)
            newItem.isSelected = true
            return
          }
        }
      default:
        // if there is already selected item
        // then try to select its knob
        if let knob = canvasView.selectedItem?.knobAt(point: point) {
          canvasView.selectedKnob = knob
          return
          // select an item if any at the point
        } else if let item = canvasView.itemAt(point: point) {
          canvasView.selectedItem = item
          item.isSelected = true
          return
        }
      }
           
      canvasView.selectedItem = nil
      
      if canvasView.selectedTextAnnotation == nil && canvasView.createMode == .text {

      } else {
        canvasView.deselectTextAnnotation()
      }
 
    }
  
  private var canvasItemSelected: Bool {
    guard let canvasView = self.canvasView else { return false }
    return canvasView.selectedItem != nil || canvasView.selectedTextAnnotation != nil
  }

}
