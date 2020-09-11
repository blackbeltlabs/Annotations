//
//  TextModel.swift
//  Annotations
//
//  Created by Mirko on 5/20/19.
//

import Foundation

public struct TextModel: Model, TextAnnotationModelable {
  public var index: Int
  public let origin: PointModel
  public let text: String
  public let textParams: TextParams
  
  private let _frame: CGRect?
  
  init(origin: PointModel,
       text: String,
       textParams: TextParams,
       index: Int) {
    
    self.origin = origin
    self.text = text
    self._frame = nil
    self.textParams = textParams
    self.index = index
  }
  
  init(origin: PointModel,
       text: String,
       frame: CGRect?,
       textParams: TextParams,
       index: Int) {
    
    self.origin = origin
    self.text = text
    self._frame = frame
    self.textParams = textParams
    self.index = index
  }
  
  public var frame: CGRect {
    if let frame = _frame {
      return frame
    } else {
      return CGRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
    }
  }
  
  func copyWithColor(color: ModelColor) -> TextModel {
    
    return TextModel(origin: origin,
                     text: text,
                     frame: frame,
                     textParams: TextParams(foregroundColor: color.textColor),
                     index: index)
    
  }
}
