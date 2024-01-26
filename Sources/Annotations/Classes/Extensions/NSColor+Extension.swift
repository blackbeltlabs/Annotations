import AppKit

extension NSColor {
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
