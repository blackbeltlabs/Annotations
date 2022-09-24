import Foundation
import Cocoa

final class ObfuscateFallbackHelper {
  static func obfuscateFallbackImage(size: NSSize, _ color: NSColor) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.drawSwatch(in: NSRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
  }
}
