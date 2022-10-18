import Foundation
import QuartzCore

final class SelectionDrawablesFactory {
  
  static func createKnobLayer(with id: String) -> ControlKnob {
    createSelectionLayer(of: ControlKnob.self, id: id, zPosition: 2)
  }

  static func createBorderLayer(with id: String) -> ControlBorder {
    createSelectionLayer(of: ControlBorder.self, id: id, zPosition: 1)
  }
  
  static func createLegibilityButton(with id: String, target: AnyObject, action: Selector) -> LegibilityControlButton {
    let button = LegibilityControlButton(frame: .zero)
    button.id = id
    button.target = target
    button.action = action
    return button
  }
  
  static func createEmojiButton(with id: String, target: AnyObject, action: Selector) -> EmojiControlButton {
    let button = EmojiControlButton(frame: .zero)
    button.id = id
    button.target = target
    button.action = action
    return button
  }
  
  // MARK: - Common
  static func createSelectionLayer<T: CALayer & DrawableElement>(of type: T.Type,
                                                                 id: String,
                                                                 zPosition: CGFloat) -> T {
    var selectionLayer = T()
    selectionLayer.id = id
    selectionLayer.zPosition = zPosition
    return selectionLayer
  }
}
