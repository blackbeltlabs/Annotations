import Cocoa

class TextKnobView: NSView {
  // MARK: - Properties
  let strokeColor: NSColor
  let fillColor: NSColor
  
  // MARK: - Init
  init(strokeColor: NSColor, fillColor: NSColor) {
    self.strokeColor = strokeColor
    self.fillColor = fillColor
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Draw
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let lineWidth: CGFloat = 1.0

    // need add inset here to ensure that drawn oval will not be clipped
    // as layer.masksToBounds didn't help to solve this problem
    let ovalRect = dirtyRect.insetBy(dx: lineWidth / 2,
                                     dy: lineWidth / 2)
    
    let path = NSBezierPath(ovalIn: ovalRect)
    fillColor.setFill()
    path.fill()
    
    path.lineWidth = lineWidth
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
