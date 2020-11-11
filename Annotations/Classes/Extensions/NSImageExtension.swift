import Cocoa

extension NSImage {
  func tint(color: NSColor) -> NSImage {
    guard !self.isTemplate else { return self }
    // swiftlint:disable:next force_cast
    let image = self.copy() as! NSImage
    image.lockFocus()
    
    color.set()
    
    let imageRect = NSRect(origin: .zero, size: image.size)
    imageRect.fill(using: .sourceAtop)
    
    image.unlockFocus()
    image.isTemplate = false
    
    return image
  }
}
