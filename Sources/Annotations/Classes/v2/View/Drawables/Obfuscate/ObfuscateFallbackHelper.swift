import Foundation
import Cocoa

final class ObfuscateRendererHelper {
  static func obfuscateFallbackImage(size: NSSize, _ color: NSColor) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.drawSwatch(in: NSRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
  }
  
  static func obfuscatePaletteImage(size: NSSize,
                                    colorPalette: [NSColor]) -> NSImage? {
    let im = NSImage(size: size)

    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                     pixelsWide: Int(size.width),
                                     pixelsHigh: Int(size.height),
                                     bitsPerSample: 8,
                                     samplesPerPixel: 4,
                                     hasAlpha: true,
                                     isPlanar: false,
                                     colorSpaceName: NSColorSpaceName.calibratedRGB,
                                     bytesPerRow: 0,
                                     bitsPerPixel: 0) else {
      return nil
    }

    im.addRepresentation(rep)
    im.lockFocus()

    let ctx = NSGraphicsContext.current?.cgContext

    let widthPart: CGFloat = 5.0
    var initialPoint: CGFloat = 0
    var initialYPoint: CGFloat = 0
    
    while initialYPoint <= size.height {
  
        while initialPoint <= size.width {
            let frame = CGRect(x: initialPoint,
                               y: initialYPoint,
                               width: widthPart,
                               height: widthPart)
                    
          ctx?.setFillColor(colorPalette.randomElement()?.cgColor ?? NSColor.black.cgColor)
          ctx?.fill(frame)
          initialPoint += widthPart
        }
        
        initialYPoint += widthPart
        initialPoint = 0
    }

    im.unlockFocus()
    return im
  }
}
