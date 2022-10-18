import AppKit

final class CursorHelper {
  lazy var defaultCursor: NSCursor = NSCursor.arrow
  
  lazy var resizeCursor: NSCursor = {
    cursor(with: "East-West", hotSpot: NSPoint(x: 9, y: 9))
  }()
  
  lazy var scaleCursor: NSCursor = {
    cursor(with: "North-West-South-East", hotSpot: NSPoint(x: 9, y: 9))
  }()
  
  lazy var moveCursor: NSCursor = {
    cursor(with: "Arrows", hotSpot: NSPoint(x: 7, y: 7))
  }()
  
  func cursor(with resourceName: String, hotSpot: NSPoint) -> NSCursor {
    guard let image = ImageHelper.imageFromBundle(named: resourceName) else {            
      return NSCursor.crosshair
    }
    return NSCursor(image: image, hotSpot: hotSpot)
  }
  
 func cursor(for type: CursorType) -> NSCursor {
    switch type {
    case .`default`:
      return defaultCursor
    case .textEditing:
      return .iBeam
    case .textMove:
      return moveCursor
    case .textResize:
      return resizeCursor
    case .textScale:
      return scaleCursor
    }
  }
}

