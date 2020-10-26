import Cocoa

class ImageHelper {
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

  func applyPixellateFilter(_ image: NSImage) -> NSImage? {
    guard let ciImage = image.ciImage else { return nil }
  
    guard let blurFilter = CIFilter(name: "CIPixellate") else {
      return nil
    }
    blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
    
    blurFilter.setValue(NSNumber(integerLiteral: 20), forKey: "inputScale")
    
    guard let outputImage = blurFilter.outputImage else {
      return nil
    }
  
    return outputImage.nsImage
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
