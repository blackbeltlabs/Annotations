import Foundation

struct ViewState<T: Model> {
    var model: T
    var isSelected: Bool
}


protocol CanvasDrawableDelegate: class {
  func drawableView(_ view: CanvasDrawable, didUpdate model: Any, atIndex index: Int)
}
