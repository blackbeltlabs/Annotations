
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
  
  static func color(from textColor: TextColor) -> NSColor {
     return NSColor(red: textColor.red,
                    green: textColor.green,
                    blue: textColor.blue,
                    alpha: textColor.alpha)
   }
   
  // MARK: - TextColor extensions
   var textColor: TextColor {
     let rgbColor: NSColor
     
     if self.colorSpace == .sRGB {
       rgbColor = self
     } else {
       if let convertedColor = usingColorSpace(.sRGB) {
         rgbColor = convertedColor
       } else { // fallback
         return TextColor(red: 0, green: 0, blue: 0, alpha: 0)
       }
     }
     
     return TextColor(red: rgbColor.redComponent,
                      green: rgbColor.greenComponent,
                      blue: rgbColor.blueComponent,
                      alpha: rgbColor.alphaComponent)
   }
}
