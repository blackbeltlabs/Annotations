import Cocoa

public class ImageHelper {
  public init() { }
  static func imageFromBundle(named: String) -> NSImage? {
    Bundle(for: Self.self).image(forResource: named)!
  }
}
