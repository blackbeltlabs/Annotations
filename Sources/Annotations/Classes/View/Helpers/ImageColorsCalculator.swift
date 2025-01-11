import AppKit

struct Pixel: Hashable, Equatable {
  let r: Float
  let g: Float
  let b: Float
  let a: Float

  init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
      self.r = Float(r)
      self.g = Float(g)
      self.b = Float(b)
      self.a = Float(a)
  }

  var color: NSColor {
    NSColor(red: CGFloat(r / 255.0),
            green: CGFloat(g / 255.0),
            blue: CGFloat(b / 255.0),
            alpha: CGFloat(a / 255.0))
  }
  
  var solidColor: NSColor {
    NSColor(red: CGFloat(r / 255.0),
            green: CGFloat(g / 255.0),
            blue: CGFloat(b / 255.0),
            alpha: 1.0)
  }

  var description: String {
    "RGBA(\(r), \(g), \(b), \(a))"
  }
  
  // do not take alpha into the consideration for the purpose of this app
  func hash(into hasher: inout Hasher) {
    hasher.combine(r)
    hasher.combine(g)
    hasher.combine(b)
  }
}

public class ImageColorsCalculator: @unchecked Sendable {
    
  public init() { }
  
  func allColors(from nsImage: NSImage) -> [Pixel: Int] {
    
    let imageSize = nsImage.size
    
    let imageRect = NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
    
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return [:]
    }
    
    
    guard let ctx: CGContext = CGContext(data: nil,
                                         width: Int(imageSize.width),
                                         height: Int(imageSize.height),
                                         bitsPerComponent: 8,
                                         bytesPerRow: 0,
                                         space: colorSpace,
                                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
      return [:]
    }
    
    let gctx = NSGraphicsContext(cgContext: ctx, flipped: false)
    
    //    // Make our bitmap context current and render the NSImage into it
    NSGraphicsContext.current = gctx
    nsImage.draw(in: imageRect)
    
    
    let colors = allColors(bitmap: ctx)
    // Clean up
    
    NSGraphicsContext.current = nil
    
    return colors
  }
  
  // the method that is suitable for obfuscate tool
  public func mostUsedColors(from nsImage: NSImage, count: Int) -> [NSColor] {
    let allPixelColors = allColors(from: nsImage)
    let mostUsed = mostUsedColors(from: allPixelColors, maxColorsCount: count)
    return mostUsed.map { $0.solidColor }
  }
  
  public func mostUsedColors(from nsImage: NSImage,
                             count: Int,
                             completion: @escaping @Sendable ([NSColor]) -> Void) {
    DispatchQueue.global().async {
      let colors = self.mostUsedColors(from: nsImage, count: count)
      completion(colors)
    }
  }
  
  func allColors(bitmap: CGContext) -> [Pixel: Int] {
    let width = bitmap.width
    let height = bitmap.height
    
    guard let pixelData = bitmap.data else {
      return [:]
    }
    
    var data = pixelData.bindMemory(to: UInt8.self,
                                    capacity: width * height)
    
    var r, g, b, a: UInt8
    
    var pixelsDict: [Pixel: Int] = [:]
    
    for _ in 0..<height {
      for _ in 0..<width {
        // get red, green, blue colors and alpha accordingly
        r = data.pointee
        data = data.advanced(by: 1)
        g = data.pointee
        data = data.advanced(by: 1)
        b = data.pointee
        data = data.advanced(by: 1)
        a = data.pointee

        data = data.advanced(by: 1)
        
        // generate new Pixel instance
        let pixel = Pixel(r: r, g: g, b: b, a: a)
        
        // increase count of a certain color if it already exists
        if let count = pixelsDict[pixel] {
          pixelsDict[pixel] = count + 1
        } else {
          // create new color with the number of occurences equals to 1
          pixelsDict[pixel] = 1
        }
      }
    }
    
    return pixelsDict
  }
  

  func mostUsedColors(from dict: [Pixel: Int], maxColorsCount: Int = 5) -> [Pixel] {
    var mostUsedColors: [Pixel] = []
    var numbersOfUsage: [Int] = []
    
    for (key, value) in dict {
      // append each color until it is less then maxColors count
      guard mostUsedColors.count >= maxColorsCount else {
        mostUsedColors.append(key)
        numbersOfUsage.append(value)
        continue
      }
      
      // if the current color (value) has more numbersOfUsage that
      // some color in array then replace it
      for i in 0..<numbersOfUsage.count {
        if numbersOfUsage[i] < value {
          numbersOfUsage[i] = value
          mostUsedColors[i] = key
          break
        }
      }
    }
    
    return mostUsedColors
  }
}


extension NSImage: @unchecked @retroactive Sendable { }
