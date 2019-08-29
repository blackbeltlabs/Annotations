//
//  TextModel.swift
//  Annotations
//
//  Created by Mirko on 5/20/19.
//

import Foundation
import TextAnnotation

public struct TextModel: Model {
  public var origin: PointModel
  public var text: String
  public var actions: [TextAnnotationActionClass]?
}
