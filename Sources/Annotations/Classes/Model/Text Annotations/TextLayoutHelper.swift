import Cocoa

final class TextLayoutHelper {
  
  static let singleLinePadding: CGFloat = 5.0
  
  static var containerLinePadding: CGFloat {
    singleLinePadding * 2.0
  }
  
  // calculate best size for string with defined attributes
  static func bestSizeWithAttributes(for string: String,
                                     attributes: [NSAttributedString.Key: Any],
                                     useEmptyStringsReplacement: Bool = true) -> CGSize {
    
    let stringToUse: String
      
    if string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .isEmpty && useEmptyStringsReplacement {
      stringToUse = "a" // just use some one letter to ensure that size will be correct
    } else {
      stringToUse = string
    }
        
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager()
    let textStorage = NSTextStorage(string: stringToUse, attributes: attributes)
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    textContainer.size = .zero // maxSize
    layoutManager.glyphRange(for: textContainer)
    layoutManager.usesDefaultHyphenation = false
    
    layoutManager.ensureLayout(for: textContainer)
    
    return layoutManager.usedRect(for: textContainer).size
  }

  static func calculateHeight(for attributedString: NSAttributedString, withWidth width: CGFloat) -> CGFloat {
    // Create a text storage object to hold the attributed string
    let textStorage = NSTextStorage(attributedString: attributedString)
    
    // Create a layout manager to layout the text
    let layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
    
    // Create a text container with the specified width and unlimited height
    let textContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    textContainer.lineFragmentPadding = TextLayoutHelper.singleLinePadding // Remove padding if needed
    textContainer.maximumNumberOfLines = 0
    layoutManager.addTextContainer(textContainer)
    
    // Calculate the required height
    layoutManager.glyphRange(for: textContainer)
    layoutManager.usesDefaultHyphenation = false
    let usedRect = layoutManager.usedRect(for: textContainer)
    
    return usedRect.height
  }

  
  // calculate height for the attributedString with defined width
  static func getHeightAttr(for attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
    let largestSize = NSSize(width: width, height: .greatestFiniteMagnitude)
    
    let textSize = getBestTextSize(for: attributedString, largestSize: largestSize)

    return ceil(textSize.height)
  }
  
  // calculate width for the attributedString with defined height
  static func getWidthAttr(for attributedString: NSAttributedString, height: CGFloat) -> CGFloat {
    let largestSize = NSSize(width: .greatestFiniteMagnitude, height: height)
    
    let textSize = getBestTextSize(for: attributedString, largestSize: largestSize)
      
    return ceil(textSize.width)
  }
  
  // low level (CoreText) method for width or height calculation
  private static func getBestTextSize(for attributedString: NSAttributedString,
                               largestSize: CGSize) -> CGSize {
    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                CFRange(),
                                                                nil,
                                                                largestSize,
                                                                nil)
    return textSize
  }
    
}
