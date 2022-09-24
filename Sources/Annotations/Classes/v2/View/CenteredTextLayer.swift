import Cocoa

final class CenteredTextLayer: CATextLayer {
  override func draw(in context: CGContext) {
    let height = self.bounds.size.height
    let fontSize = self.fontSize
    let yDiff = (height - fontSize) / 2 - fontSize / 10

    context.saveGState()
    context.translateBy(x: 0, y: yDiff) // Use -yDiff when in non-flipped coordinates (like macOS's default)
    super.draw(in: context)
    context.restoreGState()
  }
}
