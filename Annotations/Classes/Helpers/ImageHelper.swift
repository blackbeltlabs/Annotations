import Cocoa

public class ImageHelper {
  public init() { }
  static func imageFromBundle(named: String) -> NSImage? {
    Bundle(for: Self.self).image(forResource: named)!
  }
  
  // MARK: - Filters
  func applyBlurFilter(_ image: NSImage) -> NSImage? {
    guard let ciImage = image.ciImage else { return nil }
    
    let blurFilter = CIFilter(name: "CIDiscBlur")!
    blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
      
    blurFilter.setValue(NSNumber(integerLiteral: 50), forKey: "inputRadius")
      
    guard let outputImage = blurFilter.outputImage else {
      return nil
    }
    
    return outputImage.nsImage
  }

  func applyPixellateFilter(_ image: NSImage, strength: Int) -> NSImage? {
    guard let ciImage = image.ciImage else { return nil }
  
    guard let blurFilter = CIFilter(name: "CIPixellate") else {
      return nil
    }
    blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
    
    blurFilter.setValue(NSNumber(integerLiteral: strength), forKey: "inputScale")
    
    guard let outputImage = blurFilter.outputImage else {
      return nil
    }
  
    return outputImage.nsImage
  }
  
  public func trim(image: NSImage, rect: CGRect, screenScale: CGFloat = 1.0) -> NSImage {
    
    var updatedRect = rect
    
    updatedRect.origin.x *= screenScale
    updatedRect.origin.y *= screenScale
    updatedRect.size.width *= screenScale
    updatedRect.size.height *= screenScale
    
    let result = NSImage(size: updatedRect.size)
    print(image.size)
    result.lockFocus()
    
    let destRect = CGRect(origin: .zero,
                          size: result.size)
    
    image.draw(in: destRect,
               from: updatedRect,
               operation: .copy,
               fraction: 1.0,
               respectFlipped: false,
               hints: nil)

    result.unlockFocus()
    return result
  }
}

// MARK: - Extensions
private extension NSImage {
  var ciImage: CIImage? {
    guard let tiffImage = tiffRepresentation else {
      return nil
    }
    return CIImage(data: tiffImage)
  }
}

private extension CIImage {
  var nsImage: NSImage {
    let rep = NSCIImageRep(ciImage: self)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    return nsImage
  }
}
