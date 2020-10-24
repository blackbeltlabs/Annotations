import Foundation

class CanvasViewEventsHandler {
  weak var canvasView: CanvasView?
    
  func mouseDown(with event: NSEvent) {
    guard let canvasView = self.canvasView else { return }
      
    guard canvasView.isUserInteractionEnabled else { return }
        
    let point = canvasView.convert(event.locationInWindow, from: nil).pointModel
            
    canvasView.lastDraggedPoint = point
      

    switch canvasView.createMode {
    case .text:
      // specific case for text
      // texts should be created from single mouse press
      if !canvasItemSelected {
        if let newItem = canvasView.createItem(mouseDown: point,
                                                color: canvasView.createColor) {
          canvasView.add(newItem)
          newItem.doInitialSetupOnCanvas()
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
      
    // if neither new item can be created nor any can be selected
    // then need to deselect the currently selected item
    canvasView.selectedItem = nil
      
    if canvasView.createMode != .text || canvasView.selectedTextAnnotation != nil {
      canvasView.deselectTextAnnotation()
    }
  }
  
  func mouseDragged(with event: NSEvent) {
    guard let canvasView = self.canvasView else { return }
    guard canvasView.isUserInteractionEnabled else { return }
    let point = canvasView.convert(event.locationInWindow, from: nil).pointModel
    
    guard let lastDraggedPoint = canvasView.lastDraggedPoint else {
      return
    }
    
    // if item has been selected before
    // then need to move it or its knob (resize or scale)
    if let selectedItem = canvasView.selectedItem {
      if let selectedKnob = canvasView.selectedKnob {
        selectedItem.draggedKnob(selectedKnob, from: lastDraggedPoint, to: point)
      } else {
        selectedItem.dragged(from: lastDraggedPoint, to: point)
      }
      
      canvasView.isChanged = true
      canvasView.lastDraggedPoint = point
    } else {
      // if an item has not been selected before need to try to create a new one
      // if it is possible
      let (newItem, newKnob) = canvasView.createItem(dragFrom: lastDraggedPoint,
                                                     to: point,
                                                     color: canvasView.createColor)
      guard let item = newItem else {
        return
      }
      
      canvasView.add(item)
      canvasView.selectedItem = item
      canvasView.selectedKnob = newKnob
      canvasView.isChanged = true
      canvasView.lastDraggedPoint = point
    }
  }
  
  func mouseUp(with event: NSEvent) {
    guard let canvasView = self.canvasView else { return }
    guard canvasView.isUserInteractionEnabled else { return }
    
    canvasView.selectedKnob = nil
    
    if let selectedItem = canvasView.selectedItem {
      selectedItem.isSelected = true
    }
    
    // if is changed need to send delegate callback
    if canvasView.isChanged {
      canvasView.delegate?.canvasView(canvasView,
                                      didUpdateModel: canvasView.model)
      canvasView.isChanged = false
    }
    
    // clear last dragged point here
    canvasView.lastDraggedPoint = nil
  }
  
  // MARK: - Private
  private var canvasItemSelected: Bool {
    guard let canvasView = self.canvasView else { return false }
    return canvasView.selectedItem != nil || canvasView.selectedTextAnnotation != nil
  }
  
}
