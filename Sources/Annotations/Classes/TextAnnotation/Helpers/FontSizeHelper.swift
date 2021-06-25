import Cocoa

class FontSizeHelper {
  func smallestFont(with fontDescriptor: NSFontDescriptor) -> NSFont? {
    NSFont(descriptor: fontDescriptor, size: CGFloat(1))
  }
  
  func lineHeight(of font: NSFont) -> CGFloat {
    CGFloat(ceilf(Float(font.ascender + abs(font.descender) + font.leading)))
  }

  func fontFittingText(_ text: String,
                       in bounds: CGSize,
                       fontDescriptor: NSFontDescriptor) -> NSFont? {

    let properBounds = CGRect(origin: .zero, size: bounds)
    let largestFontSize = Int(bounds.height)
    let constrainingBounds = CGSize(width: properBounds.width, height: CGFloat.infinity)
    
    guard largestFontSize > 0 else { return smallestFont(with: fontDescriptor) }

    let bestFittingFontSize: Int? = (1...largestFontSize).reversed().first(where: { fontSize in

      let font = NSFont(descriptor: fontDescriptor, size: CGFloat(fontSize))
      let currentFrame = text.boundingRect(
        with: constrainingBounds,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: [.font: font as Any],
        context: nil
      )

      if properBounds.contains(currentFrame) {
        return true
      }

      return false
    })

    guard let fontSize = bestFittingFontSize else {
      return smallestFont(with: fontDescriptor)
    }

    return NSFont(descriptor: fontDescriptor, size: CGFloat(fontSize))
  }
}
