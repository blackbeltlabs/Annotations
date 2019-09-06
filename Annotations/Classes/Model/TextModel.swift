//
//  TextModel.swift
//  Annotations
//
//  Created by Mirko on 5/20/19.
//

import Foundation
import TextAnnotation

public struct TextModel: Model, TextAnnotationModelable {
  public let origin: PointModel
  public let text: String
  public let fontName: String?
  public let fontSize: CGFloat?
  public let color: TextColor
  
  private let _frame: CGRect?
  
  init(origin: PointModel, text: String, color: TextColor) {
    self.origin = origin
    self.text = text
    self._frame = nil
    self.fontName = nil
    self.fontSize = nil
    self.color = color
  }
  
  init(origin: PointModel,
       text: String,
       frame: CGRect?,
       fontName: String?,
       fontSize: CGFloat?,
       color: TextColor) {
    self.origin = origin
    self.text = text
    self._frame = frame
    self.fontName = fontName
    self.fontSize = fontSize
    self.color = color
  }
  
  public var frame: CGRect {
    if let frame = _frame {
      return frame
    } else {
      return CGRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
    }
  }
}
