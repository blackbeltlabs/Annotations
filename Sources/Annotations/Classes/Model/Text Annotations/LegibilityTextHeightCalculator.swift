import Foundation

// the height of legibility text view is larger than regular text so need to found additional height offset
// for a certain font
final class LegibilityTextHeightCalculator {
  
  // these base values are calculated empirically
  // and their values are used for the proportion to calculate for any font
  static let baseLineWidthSize: CGFloat = 8.0
  static let baseFontSize: CGFloat = 30.0
  
  static func lineWidth(for fontSize: CGFloat?) -> CGFloat {
    if let fontSize {
      return lineWidth(for: fontSize)
    } else {
      return baseLineWidthSize
    }
  }
  
  static func lineWidth(for fontSize: CGFloat) -> CGFloat {
    fontSize * baseLineWidthSize / baseFontSize
  }
  
  // an additional height that should be added to the height
  // of text view frame to ensure that content isn't clipped
  static func additionalHeight(for fontSize: CGFloat) -> CGFloat {
    let lineWidth = self.lineWidth(for: fontSize)
    return lineWidth / 2.0
  }
}
