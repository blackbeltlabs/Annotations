import Foundation

struct ViewState<T: Model> {
    var model: T
    var isSelected: Bool
}


protocol CanvasDrawableDelegate: AnyObject {
  func drawableView(_ view: CanvasDrawable, didUpdate model: Any, atIndex index: Int)
}
