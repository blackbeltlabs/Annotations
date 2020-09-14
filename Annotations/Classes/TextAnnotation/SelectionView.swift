import Cocoa

@IBDesignable
class SelectionView: NSView {
  
  var currentSelectionFrame: NSRect {
    selectionFrame(with: frame)
  }
  
  func selectionFrame(with frameRect: NSRect) -> NSRect {
    let padding = Configuration.frameMargin + Configuration.dotRadius
    return NSRect(x: padding,
                  y: padding,
                  width: frameRect.width - 2 * padding,
                  height: frameRect.height - 2 * padding)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let framePath = NSBezierPath(rect: selectionFrame(with: dirtyRect))
    
    framePath.lineWidth = Configuration.controlStrokeWidth
    Palette.frameStrokeColor.set()
    framePath.stroke()
    framePath.close()
  }
}

