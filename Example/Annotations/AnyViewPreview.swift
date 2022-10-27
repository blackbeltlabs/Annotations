import SwiftUI

struct AnyViewPreview<T: NSView>: NSViewRepresentable {
  let customSetupHandler: ((T) -> Void)?
  let customInitializer: (() -> T)?
  
  init(customSetupHandler: ((T) -> Void)? = nil,
       customInitializer: (() -> T)? = nil) {
    self.customSetupHandler = customSetupHandler
    self.customInitializer = customInitializer
  }
  
  func makeNSView(context: Context) -> T {
    let item: T = customInitializer?() ?? T(frame: .zero)
    if let customSetupHandler = customSetupHandler {
      customSetupHandler(item)
    }
    return item
  }
  
  func updateNSView(_ nsViewController: T, context: Context) { }
}
