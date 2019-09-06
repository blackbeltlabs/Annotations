
import Foundation

extension NSColor {
  static var annotations: NSColor {
    return #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1)
  }
  
  static var knob: NSColor {
    return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
  }
  
  static var obfuscate: NSColor {
    return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
  }
  
  public static func color(from modelColor: ModelColor) -> NSColor {
    return NSColor(red: modelColor.red,
                   green: modelColor.green,
                   blue: modelColor.blue,
                   alpha: modelColor.alpha)
  }
  
  public var annotationModelColor: ModelColor {
    return ModelColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
  }
}
