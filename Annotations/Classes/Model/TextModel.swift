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
  public let style: TextParams
  public let legibilityEffectEnabled: Bool
  
  public var modelColor: ModelColor? {
    return style.foregroundColor
  }
  
  private let _frame: CGRect?
  
  init(origin: PointModel,
       text: String,
       textParams: TextParams,
       index: Int) {
    
    self.origin = origin
    self.text = text
    self._frame = nil
    self.style = textParams
    self.index = index
    self.legibilityEffectEnabled = false
  }
  
  init(origin: PointModel,
       text: String,
       frame: CGRect?,
       textParams: TextParams,
       index: Int,
       legibilityEffectEnabled: Bool) {
    
    self.origin = origin
    self.text = text
    self._frame = frame
    self.style = textParams
    self.index = index
    self.legibilityEffectEnabled = legibilityEffectEnabled
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
                     textParams: TextParams(foregroundColor: color),
                     index: index,
                     legibilityEffectEnabled: legibilityEffectEnabled)
    
  }
  
  public func copyWithTextParams(_ textParams: TextParams) -> TextModel {
    TextModel(origin: origin,
              text: text,
              frame: frame,
              textParams: textParams,
              index: index,
              legibilityEffectEnabled: legibilityEffectEnabled)
  }
}
