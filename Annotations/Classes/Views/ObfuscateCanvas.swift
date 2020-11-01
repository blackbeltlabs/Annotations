import Foundation

protocol ObfuscateCanvas: class, ObfuscateViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension ObfuscateCanvas {
  func redrawObfuscate(model: ObfuscateModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.obfuscates.firstIndex(of: model) else { return }
    let state = ObfuscateViewState(model: model, isSelected: false)
    let view = ObfuscateView(state: state,
                             modelIndex: modelIndex,
                             globalIndex: model.index,
                             color: model.color)
    view.delegate = self
    add(view)
  }
  
  func createObfuscateView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = ObfuscateModel(index: model.elements.count + 1,
                                 origin: origin,
                                 to: to,
                                 color: color)
    
    model.obfuscates.append(newRect)
    
    let state = ObfuscateViewState(model: newRect, isSelected: false)
    let newView = ObfuscateView(state: state,
                                modelIndex: model.obfuscates.count - 1,
                                globalIndex: newRect.index,
                                color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(obfuscate: ObfuscateView) -> CanvasModel {
    return model.copyWithout(type: .obfuscate, index: obfuscate.modelIndex)
  }
  
  func obfuscateView(_ view: ObfuscateView, didUpdate model: ObfuscateModel, atIndex index: Int) {
    self.model.obfuscates[index] = model
  }
  
  
  func generateObfuscatePaletteImage(size: NSSize,
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
  
  func obfuscateFallbackImage(size: NSSize, _ color: NSColor) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.drawSwatch(in: NSRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
  }
}
