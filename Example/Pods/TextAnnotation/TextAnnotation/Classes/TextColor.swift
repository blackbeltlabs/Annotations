
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
