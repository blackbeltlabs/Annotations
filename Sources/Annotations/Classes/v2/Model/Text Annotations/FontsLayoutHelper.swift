import Cocoa

final class FontsLayoutHelper {
 
  static func fontSize(for text: String, from fontSizes: [Int], fontName: String, properBounds: CGRect) -> Int? {
    let constrainingBounds = CGSize(width: properBounds.width, height: CGFloat.infinity)
    return fontSizes.first { fontSize in
      guard let font = NSFont(name: fontName, size: CGFloat(fontSize)) else { return false }
      
      let boundingRectForThisFont = text.boundingRect(with: constrainingBounds,
                                                      options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                      attributes: [.font: font],
                                                      context: nil)
      
      return properBounds.contains(boundingRectForThisFont)
    }
  }

  static func fontFittingText(_ text: String,
                              in bounds: CGSize,
                              fontName: String,
                              scaleUp: Bool,
                              currentFontSize: Double) -> CGFloat {
    
    
    if let quickResult = quickFontFittingTextSize(text,
                                                  in: bounds,
                                                  fontName: fontName,
                                                  scaleUp: scaleUp,
                                                  currentFontSize: currentFontSize) {
      return quickResult
    } else {
      return fontFittingText(text, in: bounds, fontName: fontName)
    }
  }
  
  // try to predict the next font size depending on scale direction
  // much quicker than brute-force algorithm as usually the fontSize is fontSize + 1 or fontSize - 1
  // depending on scale direction
  static func quickFontFittingTextSize(_ text: String,
                                       in boundsSize: CGSize,
                                       fontName: String,
                                       scaleUp: Bool,
                                       currentFontSize: Double) -> CGFloat? {
    let textBounds = CGRect(origin: .zero, size: boundsSize)
    
    let sequence: ReversedCollection<ClosedRange<Int>> = {
      if scaleUp {
        return (Int(currentFontSize)...Int(currentFontSize + 2)).reversed()
      } else {
        return (1...Int(currentFontSize)).reversed()
      }
    }()
    
    let array = Array<Int>(sequence)
    
    if let foundFontSize = fontSize(for: text, from: array, fontName: fontName, properBounds: textBounds) {
      return CGFloat(foundFontSize)
    } else {
      return nil
    }
  }
  
  
  // brute force algorithm
  static func fontFittingText(_ text: String,
                              in bounds: CGSize,
                              fontName: String) -> CGFloat {

    let properBounds = CGRect(origin: .zero, size: bounds)
    let largestFontSize = Int(bounds.height)
    
    guard largestFontSize > 0 else { return 1.0 }
    
    let sequence = (1...largestFontSize).reversed()
    let array = Array<Int>(sequence)
    
    if let found = fontSize(for: text, from: array, fontName: fontName, properBounds: properBounds) {
      return CGFloat(found)
    } else {
      return 1.0
    }
  }
}
