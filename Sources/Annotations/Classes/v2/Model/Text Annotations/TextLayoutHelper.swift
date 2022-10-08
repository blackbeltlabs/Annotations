import Cocoa

final class TextLayoutHelper {
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
    if #available(OSX 10.15, *) {
      layoutManager.usesDefaultHyphenation = false
    } else {
      layoutManager.hyphenationFactor = 0
    }
    
    layoutManager.ensureLayout(for: textContainer)
    
    return layoutManager.usedRect(for: textContainer).size
  }
}
