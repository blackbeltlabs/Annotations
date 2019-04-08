//
//  Model.swift
//  Annotate
//
//  Created by Mirko on 12/26/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Foundation

public enum CanvasItemType {
//    case text
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
  var arrows: [ArrowModel]
  var pens: [PenModel]
  var rects: [RectModel] = []
  
  static var empty: CanvasModel {
    return CanvasModel(arrows: [], pens: [], rects: [])
  }
  
  func copy(arrows: [ArrowModel]? = nil, pens: [PenModel]? = nil, rects: [RectModel]? = nil) -> CanvasModel {
    return CanvasModel(
      arrows: arrows ?? self.arrows,
      pens: pens ?? self.pens,
      rects: rects ?? self.rects
    )
  }
  
  func copyWithout(type: CanvasItemType, index: Int) -> CanvasModel {
    switch type {
    case .arrow:
      return copy(arrows: arrows.copyWithout(index: index))
    case .pen:
        return copy(pens: pens.copyWithout(index: index))
    case .rect:
      return copy(rects: rects.copyWithout(index: index))
    }
  }
}
