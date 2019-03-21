//
//  Array.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/7/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

extension Array {
  func copyWithout(index: Int) -> Array {
    return Array(prefix(upTo: index)) + Array(suffix(from: index + 1))
  }
}
