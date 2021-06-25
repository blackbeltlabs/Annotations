//
//  StringExtension.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/7/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa

extension String {
  func sizeWithFont(_ font: NSFont, maxSize: CGSize) -> CGSize {
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager()
    let textStorage = NSTextStorage(string: self, attributes: [.font : font])
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    textContainer.size = maxSize
    layoutManager.glyphRange(for: textContainer)
    layoutManager.hyphenationFactor = 0.0
    layoutManager.ensureLayout(for: textContainer)
    
    return layoutManager.usedRect(for: textContainer).size
  }
}
