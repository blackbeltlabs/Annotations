//
//  Cursor.swift
//  TextAnnotation
//
//  Created by Mirko on 5/19/19.
//

import Foundation

class CursorSet {
  static var shared = CursorSet()
  
  lazy var defaultCursor: NSCursor = NSCursor.arrow
  
  lazy var resizeCursor: NSCursor = {
    guard let image = Bundle(for: CursorSet.self).image(forResource: "East-West") else { return NSCursor.crosshair }
    return NSCursor(image: image, hotSpot: NSPoint(x: 9, y: 9))
  }()
  
  lazy var scaleCursor: NSCursor = {
    guard let image = Bundle(for: CursorSet.self).image(forResource: "North-West-South-East") else { return NSCursor.crosshair }
    return NSCursor(image: image, hotSpot: NSPoint(x: 9, y: 9))
  }()
}
