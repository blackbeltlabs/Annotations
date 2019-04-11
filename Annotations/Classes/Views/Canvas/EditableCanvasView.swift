//
//  EditableCanvasView.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public protocol EditableCanvasView: CanvasView {
  var createMode: CanvasItemType { get set }
  var isChanged: Bool { get set }
  var selectedKnob: KnobView? { get set }
  var lastDraggedPoint: PointModel? { get set }
  var selectedItem: CanvasDrawable? { get set }
  
  func delete(item: CanvasDrawable) -> CanvasModel
  func createItem(mouseDown: PointModel) -> (CanvasDrawable?, KnobView?)
  func createItem(dragFrom: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?)
}

extension EditableCanvasView {
  func didUpdate(selectedItem: CanvasDrawable?, oldValue: CanvasDrawable?) {
    oldValue?.isSelected = false
  }
  
  public func deleteSelectedItem() {
    guard let selectedItem = selectedItem else {
      return
    }
    
    let newModel = delete(item: selectedItem)
    update(model: newModel)
    delegate?.canvasView(self, didUpdateModel: newModel)
  }
  
  func itemAt(point: PointModel) -> CanvasDrawable? {
    return items.first(where: { (item) -> Bool in
      return item.contains(point: point)
    })
  }
  
  func mouseDown(_ location: PointModel) {
    lastDraggedPoint = location
    
    if let knob = selectedItem?.knobAt(point: location) {
      selectedKnob = knob
      return
    }
    
    guard let item = itemAt(point: location) else {
      selectedItem = nil
      return
    }
    
    selectedItem = item
    item.isSelected = true
  }
  
  func mouseDragged(_ location: PointModel) {
    let lastDraggedPoint = self.lastDraggedPoint!
    
    // create new item
    if selectedItem == nil {
      let (newItem, newKnob) = createItem(dragFrom: lastDraggedPoint, to: location)
      
      if let item = newItem {
        add(item)
        selectedItem = item
        selectedKnob = newKnob
        isChanged = true
        self.lastDraggedPoint = location
      }
      
      return
    }
    
    guard let selectedItem = selectedItem else {
      return
    }
    
    if let selectedKnob = self.selectedKnob {
      selectedItem.draggedKnob(selectedKnob, from: lastDraggedPoint, to: location)
    } else {
      selectedItem.dragged(from: lastDraggedPoint, to: location)
    }
    
    isChanged = true
    self.lastDraggedPoint = location
  }
  
  func mouseUp(_ location: PointModel) {
    selectedKnob = nil
    
    if let selectedItem = selectedItem {
      selectedItem.isSelected = true
    }
    
    if isChanged {
      delegate?.canvasView(self, didUpdateModel: model)
      isChanged = false
    }
  }
}
