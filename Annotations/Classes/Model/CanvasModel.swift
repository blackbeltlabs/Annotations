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
  case obfuscate
  case highlight
}

public protocol Indexable {
  var index: Int { get set }
}

public protocol Model: Codable, CustomStringConvertible, Equatable, Indexable {}
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
  public var index: Int = 0
  public var texts: [TextModel] = []
  public var arrows: [ArrowModel] = []
  public var pens: [PenModel] = []
  public var rects: [RectModel] = []
  public var obfuscates: [ObfuscateModel] = []
  public var highlights: [HighlightModel] = []
  
  public var elements: [Indexable] {
    var elements: [Indexable] = texts + arrows + pens
    elements.append(contentsOf: rects + obfuscates + highlights)
    return elements
  }
  
  public var elementsSorted: [Indexable] {
    elements.sorted(by: { $0.index < $1.index })
  }
  
  public init() {}
  
  func copy(texts: [TextModel]? = nil,
            arrows: [ArrowModel]? = nil,
            pens: [PenModel]? = nil,
            rects: [RectModel]? = nil,
            obfuscates: [ObfuscateModel]? = nil,
            highlights: [HighlightModel]? = nil) -> CanvasModel {
    
    var newModel = CanvasModel()
    newModel.texts = texts ?? self.texts
    newModel.arrows = arrows ?? self.arrows
    newModel.pens = pens ?? self.pens
    newModel.rects = rects ?? self.rects
    newModel.obfuscates = obfuscates ?? self.obfuscates
    newModel.highlights = highlights ?? self.highlights
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
    case .obfuscate:
      return copy(obfuscates: obfuscates.copyWithout(index: index))
    case .highlight:
      return copy(highlights: highlights.copyWithout(index: index))
    }
  }
}

