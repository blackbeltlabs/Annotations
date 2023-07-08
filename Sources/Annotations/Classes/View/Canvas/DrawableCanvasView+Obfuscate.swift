import Cocoa

extension DrawableCanvasView {
  func renderObfuscatedAreaBackground(_ type: ObfuscatedAreaType) {
    switch type {
    case .solidColor(let color):
      guard frame.size.width > 0 && frame.size.height > 0 else {
        return
      }
      
      let fallbackImage = ObfuscateRendererHelper.obfuscateFallbackImage(size: frame.size,
                                                                         color)
      obfuscateLayer.setObfuscatedAreaContents(fallbackImage)
    case .image(let image):
      let size = frame.size
      imageColorsCalculator.mostUsedColors(from: image, count: 5) { [weak self] colors in
        guard let self = self else { return }
        let paletteImage = ObfuscateRendererHelper.obfuscatePaletteImage(size: size,
                                                                         colorPalette: colors)
        
        DispatchQueue.main.async {
          if let paletteImage {
            self.obfuscateLayer.setObfuscatedAreaContents(paletteImage)
          } else {
            self.renderObfuscatedAreaBackground(.solidColor(.black))
          }
        }
      }
    }
  }
}
