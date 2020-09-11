
import Foundation

// convert to TextColor for TextAnnotations
extension ModelColor {
  var textColor: TextColor {
    return TextColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

public extension TextColor {
  var modelColor: ModelColor {
    return ModelColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
