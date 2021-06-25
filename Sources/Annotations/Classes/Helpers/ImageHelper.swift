import Cocoa

public class ImageHelper {
  public init() { }
  static func imageFromBundle(named: String) -> NSImage? {
    #if SWIFT_PACKAGE
      let bundle = Bundle.module
    #else // to still support CocoaPods
      let bundle = Bundle(for: Self.self)
    #endif
    return bundle.image(forResource: named)!
  }
}
