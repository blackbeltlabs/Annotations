import Cocoa

extension NSColor {
  static var knob: NSColor {
    .white
  }
  
  static var obfuscate: NSColor {
      .init(red: 65.0 / 255.0, green: 70.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
  }
  
  static var zapierOrange: NSColor {
    .init(red: 255.0 / 255.0, green: 76.0 / 255.0, blue: 0, alpha: 1.0)
  }
  
  public static func color(from modelColor: ModelColor) -> NSColor {
    return NSColor(red: modelColor.red,
                   green: modelColor.green,
                   blue: modelColor.blue,
                   alpha: modelColor.alpha)
  }
  
  public var annotationModelColor: ModelColor {
    let rgbColor: NSColor
    if self.colorSpace == .sRGB {
      rgbColor = self
    } else {
      if let convertedColor = usingColorSpace(.sRGB) {
        rgbColor = convertedColor
      } else { // fallback
        return ModelColor(red: 0, green: 0, blue: 0, alpha: 0)
      }
    }
        
    return ModelColor(red: rgbColor.redComponent,
                      green: rgbColor.greenComponent,
                      blue: rgbColor.blueComponent,
                      alpha: rgbColor.alphaComponent)
  }

}
