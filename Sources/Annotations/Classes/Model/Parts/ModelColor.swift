import CoreGraphics

public struct ModelColor: Codable, Equatable {
  public let red: CGFloat
  public let green: CGFloat
  public let blue: CGFloat
  public let alpha: CGFloat
  
  // MARK: - Convenient properties to get common used colors
  
  public static let orange: ModelColor = {
    return .colorFromRelative(red: 255.0, green: 74.0, blue: 1.0)
  }()
  
  public static let yellow: ModelColor = {
    return .colorFromRelative(red: 255.0, green: 196.0, blue: 62.0)
  }()
  
  public static let green: ModelColor = {
    return .colorFromRelative(red: 19.0, green: 208.0, blue: 171.0)
  }()
  
  public static let fuschia: ModelColor = {
    return .colorFromRelative(red: 252.0, green: 28.0, blue: 116.0)
  }()
  
  public static let violet: ModelColor = {
    return .colorFromRelative(red: 96.0, green: 97.0, blue: 237.0)
  }()
  
  public static let transparent: ModelColor = {
    return .colorFromRelative(red: 0, green: 0, blue: 0, alpha: 0.5)
  }()
  
  // MARK: - Default colors
  
  public static func defaultColor() -> ModelColor {
    return orange
  }
  
  public static func defaultColors() -> [ModelColor] {
    return [orange, yellow, green, fuschia, violet]
  }
  
  public static var zero: ModelColor {
    Self.init(red: 0, green: 0, blue: 0, alpha: 0)
  }
  // MARK: - Helpers

  public static func colorFromRelative(red: CGFloat,
                                       green: CGFloat,
                                       blue: CGFloat,
                                       alpha: CGFloat = 1.0) -> ModelColor {
    return ModelColor(red: red / 255.0,
                      green: green / 255.0,
                      blue: blue / 255.0,
                      alpha: alpha)
  }
  
  public static func random() -> ModelColor {
    ModelColor(red: CGFloat.random(in: 0..<1.0),
               green: CGFloat.random(in: 0..<1.0),
               blue: CGFloat.random(in: 0..<1.0),
               alpha: 1.0)
  }
}
