//
//  CAShapeLayerExtension.swift
//  Annotate
//
//  Created by Mirko on 12/30/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa

extension CAShapeLayer {
  var shapePath: CGPath? {
    set {
      guard let newValue = newValue else {
        return
      }
      
      path = newValue
      bounds = newValue.boundingBox
      frame = bounds
    }
    get {
      return path
    }
  }
}
