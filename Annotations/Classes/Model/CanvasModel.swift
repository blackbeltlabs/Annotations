//
//  Model.swift
//  Annotate
//
//  Created by Mirko on 12/26/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Foundation

public enum CanvasItemType {
  case arrow
  case rect
  case pen
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
  var arrows: [ArrowModel]
  var rects: [RectModel]
  var pens: [PenModel]
  
  static var empty: CanvasModel {
    return CanvasModel(arrows: [], rects: [], pens: [])
  }
  
  func copy(arrows: [ArrowModel]? = nil, rects: [RectModel]? = nil, pens: [PenModel]? = nil) -> CanvasModel {
    return CanvasModel(
      arrows: arrows ?? self.arrows,
      rects: rects ?? self.rects,
      pens: pens ?? self.pens
    )
  }
  
  func copyWithout(type: CanvasItemType, index: Int) -> CanvasModel {
    switch type {
    case .arrow:
      return copy(arrows: arrows.copyWithout(index: index))
    case .rect:
      return copy(rects: rects.copyWithout(index: index))
    case .pen:
      return copy(pens: pens.copyWithout(index: index))
    }
  }
}
