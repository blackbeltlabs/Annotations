//
//  TextModel.swift
//  Annotations
//
//  Created by Mirko on 5/20/19.
//

import Foundation
import TextAnnotation

public struct TextModel: Model, TextAnnotationModelable {
  public var origin: PointModel
  public var text: String
  private var _frame: CGRect?
  
  public var fontName: String?
  public var fontSize: CGFloat?
  
  init(origin: PointModel, text: String) {
    self.origin = origin
    self.text = text
  }
  
  init(origin: PointModel, text: String, frame: CGRect?, fontName: String?, fontSize: CGFloat?) {
    self.origin = origin
    self.text = text
    self._frame = frame
    self.fontName = fontName
    self.fontSize = fontSize
  }
  
  public var frame: CGRect {
    if let frame = _frame {
      return frame
    } else {
      return CGRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
    }
  }
}
