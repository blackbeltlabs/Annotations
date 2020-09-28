import Cocoa

class SelectionView: NSView {
  
  // MARK: - Properties
  let strokeColor: NSColor
  let lineWidth: CGFloat
  
  // MARK: - Init
  init(strokeColor: NSColor, lineWidth: CGFloat) {
    self.strokeColor = strokeColor
    self.lineWidth = lineWidth
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Draw
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let framePath = NSBezierPath(rect: dirtyRect)
    
    framePath.lineWidth = lineWidth
    strokeColor.set()
    framePath.stroke()
    framePath.close()
  }
}


// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct SelectionViewPreview: NSViewRepresentable {
  func makeNSView(context: Context) -> SelectionView {
    SelectionView(strokeColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
                  lineWidth: 10.0)
  }

  func updateNSView(_ view: SelectionView, context: Context) {
    
  }
}

@available(OSX 10.15.0, *)
struct SelectionView_Previews: PreviewProvider {
    static var previews: some View {
      SelectionViewPreview()

    }
}
#endif
