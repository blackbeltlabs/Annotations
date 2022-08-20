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
      vc.view = NSView(frame: .init(origin: .zero, size: windowSize))
    }
    
    windowController.contentViewController = vc
    
    return windowController
  }
}
