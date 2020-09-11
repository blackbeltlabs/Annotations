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
    
    let padding = Configuration.frameMargin + Configuration.dotRadius
    let framePath = NSBezierPath(rect: selectionFrame(with: dirtyRect))
    
    framePath.lineWidth = Configuration.controlStrokeWidth
    Palette.frameStrokeColor.set()
    framePath.stroke()
    framePath.close()
    
    let side = 2*Configuration.dotRadius - Configuration.controlStrokeWidth
    
    var squareRect = CGRect(x: padding - side / 2.0,
                            y: dirtyRect.height / 2.0 - side / 2.0,
                            width: side,
                            height: side)
    
    var path = NSBezierPath(ovalIn: squareRect)
    Palette.controlFillColor.setFill()
    path.fill()
    
    Palette.controlStrokeColor.setFill()
    path.stroke()
    
    // right
    squareRect = CGRect(x: dirtyRect.width - padding - side / 2.0,
                        y: dirtyRect.height / 2.0 - side / 2.0,
                        width: side,
                        height: side)
    path = NSBezierPath(ovalIn: squareRect)
    Palette.controlFillColor.setFill()
    path.fill()
    
    Palette.controlStrokeColor.setFill()
    path.stroke()
  }
}

