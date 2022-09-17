import Cocoa

// MARK: - NSColor adapters
extension ModelColor {
  var nsColor: NSColor {
    .init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
