import Foundation
import AppKit

final class PlaygroundControllerAssembler {
  static func assemble() -> NSWindowController {
    let windowSize = CGSize(width: 600, height: 600)
    let window = NSWindow(contentRect: .init(origin: .zero,
                                             size: windowSize),
                          styleMask: [.closable, .miniaturizable, .titled],
                          backing: .buffered,
                          defer: true)
    
    window.minSize = windowSize
    
    window.title = "Playground"
    let windowController = NSWindowController(window: window)
    let vc = PlaygroundViewController()
   
    vc.loadViewClosure = { vc in
      let view = MainView(frame: .init(origin: .zero, size: windowSize))
      vc.view = view
    }
    
    windowController.contentViewController = vc
    
    return windowController
  }
}

final class MainView: NSView {
  override var acceptsFirstResponder: Bool { true }
}
