//
//  PenModel.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public struct PenModel: Model {
  public var index: Int
  public var points: [PointModel]
  public let color: ModelColor
  
  func copyWithColor(color: ModelColor) -> PenModel {
    .init(index: index, points: points, color: color)
  }
}
