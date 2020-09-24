import Cocoa
import CoreText


class StringSizeHelper {
  func getHeightAttr(for attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
    let largestSize = NSSize(width: width, height: .greatestFiniteMagnitude)
    
    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, largestSize, nil)
    return ceil(textSize.height)
  }
  
  func getWidthAttr(for attributedString: NSAttributedString, height: CGFloat) -> CGFloat {
    
    let largestSize = NSSize(width: .greatestFiniteMagnitude, height: height)
    
    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, largestSize, nil)
    return ceil(textSize.width)
  }
  
  func bestSizeWithAttributes(for string: String,
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
    if #available(OSX 10.15, *) {
      layoutManager.usesDefaultHyphenation = false
    } else {
      layoutManager.hyphenationFactor = 0
      // Fallback on earlier versions
    }
    layoutManager.ensureLayout(for: textContainer)
    
    return layoutManager.usedRect(for: textContainer).size
  }
}
