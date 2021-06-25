//
//  PointExtension.swift
//  Annotate
//
//  Created by Mirko on 12/28/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa

extension CGPoint {
  func centeredRectangle(size: CGSize) -> CGRect {
    let centerTransform = CGAffineTransform(translationX: -size.width / 2, y: -size.height / 2)
    let origin = applying(centerTransform)
    return CGRect(origin: origin, size: size)
  }
  
  func centeredSquare(width: CGFloat) -> CGRect {
    return centeredRectangle(size: CGSize(width: width, height: width))
  }
}
