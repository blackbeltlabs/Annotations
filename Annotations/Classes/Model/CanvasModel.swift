//
//  Model.swift
//  Annotate
//
//  Created by Mirko on 12/26/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Foundation

public enum CanvasItemType {
  case text
  case arrow
  case pen
  case rect
}

public protocol Model: Decodable, Encodable, CustomStringConvertible, Equatable {}
extension Model {
  var json: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let result = try! encoder.encode(self)
    return String(data: result, encoding: .utf8)!
  }
  
  public var description: String {
    return json
  }
}

public struct CanvasModel: Model {
  public var texts: [TextModel] = []
  public var arrows: [ArrowModel] = []
  public var pens: [PenModel] = []
  public var rects: [RectModel] = []
  
  public init() {}
  
  func copy(texts: [TextModel]? = nil,arrows: [ArrowModel]? = nil, pens: [PenModel]? = nil, rects: [RectModel]? = nil) -> CanvasModel {
    var newModel = CanvasModel()
    newModel.texts = texts ?? self.texts
    newModel.arrows = arrows ?? self.arrows
    newModel.pens = pens ?? self.pens
    newModel.rects = rects ?? self.rects
    return newModel
  }
  
  func copyWithout(type: CanvasItemType, index: Int) -> CanvasModel {
    switch type {
    case .text:
      return copy(texts: texts.copyWithout(index: index))
    case .arrow:
      return copy(arrows: arrows.copyWithout(index: index))
    case .pen:
      return copy(pens: pens.copyWithout(index: index))
    case .rect:
      return copy(rects: rects.copyWithout(index: index))
    }
  }
}

