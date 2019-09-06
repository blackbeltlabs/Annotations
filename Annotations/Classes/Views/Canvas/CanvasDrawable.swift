//
//  CanvasDrawable.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public protocol CanvasDrawable: class {
  static var modelType: CanvasItemType { get }

  var modelIndex: Int { get set }
  var isSelected: Bool { get set }
  var color: NSColor { get }
  func addTo(canvas: CanvasView)
  func removeFrom(canvas: CanvasView)
  func contains(point: PointModel) -> Bool
  func knobAt(point: PointModel) -> KnobView?
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel)
  func dragged(from: PointModel, to: PointModel)
}

extension CanvasDrawable {
  public var modelType: CanvasItemType {
    return type(of: self).modelType
  }
}
