
import Foundation

public struct TextColor: Codable, Equatable {
  public let red: CGFloat
  public let green: CGFloat
  public let blue: CGFloat
  public let alpha: CGFloat
  
  public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }
  
  public static func defaultColor() -> TextColor {
    return TextColor(red: 1.0,
                     green: 0.3803921569,
                     blue: 0.0,
                     alpha: 1.0)
  }
}

// colors from Zappy app
extension TextColor {
  public static let orange: TextColor = {
    return .colorFromRelative(red: 255.0, green: 74.0, blue: 1.0)
  }()
  
  public static let yellow: TextColor = {
    return .colorFromRelative(red: 255.0, green: 196.0, blue: 62.0)
  }()
  
  public static let green: TextColor = {
    return .colorFromRelative(red: 19.0, green: 208.0, blue: 171.0)
  }()
  
  public static let fuschia: TextColor = {
    return .colorFromRelative(red: 252.0, green: 28.0, blue: 116.0)
  }()
  
  public static let violet: TextColor = {
    return .colorFromRelative(red: 96.0, green: 97.0, blue: 237.0)
  }()
  
  static func colorFromRelative(red: CGFloat,
                                       green: CGFloat,
                                       blue: CGFloat,
                                       alpha: CGFloat = 1.0) -> TextColor {
    return TextColor(red: red / 255.0,
                     green: green / 255.0,
                     blue: blue / 255.0,
                     alpha: alpha)
  }
}
