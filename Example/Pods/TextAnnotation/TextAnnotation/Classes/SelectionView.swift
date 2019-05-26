import Cocoa

@IBDesignable
class SelectionView: NSView {
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let padding = Configuration.frameMargin + Configuration.dotRadius
    let framePath = NSBezierPath(rect: NSRect(x: padding,
                                              y: padding,
                                              width: dirtyRect.width - 2 * padding,
                                              height: dirtyRect.height - 2 * padding))
    
    framePath.lineWidth = Configuration.controlStrokeWidth
    Palette.frameStrokeColor.set()
    framePath.stroke()
    framePath.close()
    
    let side = 2*Configuration.dotRadius - Configuration.controlStrokeWidth
    
    // left
    var squareRect = CGRect(x: Configuration.frameMargin,
                            y: (dirtyRect.height - Configuration.dotRadius)/2,
                            width: side,
                            height: side)
    var path = NSBezierPath(ovalIn: squareRect)
    Palette.controlFillColor.setFill()
    path.fill()
    
    Palette.controlStrokeColor.setFill()
    path.stroke()
    
    // right
    squareRect = CGRect(x: dirtyRect.width - (Configuration.frameMargin + 2*Configuration.dotRadius),
                        y: (dirtyRect.height - Configuration.dotRadius)/2,
                        width: side,
                        height: side)
    path = NSBezierPath(ovalIn: squareRect)
    Palette.controlFillColor.setFill()
    path.fill()
    
    Palette.controlStrokeColor.setFill()
    path.stroke()
  }
}

