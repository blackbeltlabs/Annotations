import Cocoa

class TextKnobView: NSView {
  
  let strokeColor: NSColor
  let fillColor: NSColor
  
  init(strokeColor: NSColor, fillColor: NSColor) {
    self.strokeColor = strokeColor
    self.fillColor = fillColor
    super.init(frame: .zero)
  }
  
  override var wantsDefaultClipping: Bool {
      return false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    wantsLayer = true
    layer?.masksToBounds = false
    
    let path = NSBezierPath(ovalIn: dirtyRect)
    fillColor.setFill()
    path.fill()
    
    path.lineWidth = 1
    strokeColor.setStroke()
    path.stroke()
    
  }
}


// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct TextKnobViewPreview: NSViewRepresentable {
  func makeNSView(context: Context) -> TextKnobView {
    TextKnobView(strokeColor: .white, fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  }

  func updateNSView(_ view: TextKnobView, context: Context) {
  }
}

@available(OSX 10.15.0, *)
struct TextKnobView_Previews: PreviewProvider {
    static var previews: some View {
      TextKnobViewPreview()
        .padding()
        .background(Color.green)
        .previewLayout(.fixed(width: 50, height: 50))
    }
}
#endif
