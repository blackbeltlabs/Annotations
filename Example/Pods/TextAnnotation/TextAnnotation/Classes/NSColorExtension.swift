
import AppKit

public extension NSColor {
  static func color(from textColor: TextColor) -> NSColor {
    return NSColor(red: textColor.red,
                   green: textColor.green,
                   blue: textColor.blue,
                   alpha: textColor.alpha)
  }
  
  var textColor: TextColor {
    return TextColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
  }
}
