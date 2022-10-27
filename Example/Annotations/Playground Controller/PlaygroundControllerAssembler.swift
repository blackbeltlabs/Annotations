import Foundation
import AppKit

final class PlaygroundControllerAssembler{
  static func assemble(with image: NSImage, jsonURL: URL, withControls: Bool) -> NSWindowController {
    
    let imageSize = image.size
    let windowSize = CGSize(width: imageSize.width, height: imageSize.height)
    
    
    let window = NSWindow(contentRect: .init(origin: .zero,
                                             size: windowSize),
                          styleMask: [.closable, .miniaturizable, .titled],
                          backing: .buffered,
                          defer: true)
    
    window.minSize = windowSize
    
    window.title = "Playground"
    let windowController = NSWindowController(window: window)
    let vc = PlaygroundViewController(image: image,
                                      url: jsonURL,
                                      withControls: withControls)
   
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
  
  var viewLayoutClosure: (() -> Void)? = nil
  
  override func layout() {
    super.layout()
    viewLayoutClosure?()
  }
}

extension Bundle {
  static func jsonURL(_ string: String) -> URL {
    let parts = string.components(separatedBy: ".")
    return Bundle.main.url(forResource: parts[0],
                           withExtension: parts[1])!
  }
}
