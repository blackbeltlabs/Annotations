
import TextAnnotation

// convert to TextColor for TextAnnotations
extension ModelColor {
  var textColor: TextColor {
    return TextColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
