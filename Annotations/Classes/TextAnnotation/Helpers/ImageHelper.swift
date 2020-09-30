import Cocoa

class ImageHelper {

    static func imageFromBundle(named: String) -> NSImage? {
      Bundle(for: Self.self).image(forResource: named)!
    }
}
