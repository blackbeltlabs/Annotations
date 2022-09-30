import Foundation
import CoreGraphics

class MouseInteractionHandler {
  func handleMouseDown(point: CGPoint) {
    print("Need handle mouse down = \(point)")
  }
  
  func handleMouseDragged(point: CGPoint) {
    print("Need handle mouse dragged = \(point)")
  }
  
  
  func handleMouseUp(point: CGPoint) {
    print("Need handle mouse up = \(point)")
  }
}
