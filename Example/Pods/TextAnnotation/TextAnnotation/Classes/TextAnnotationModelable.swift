
import Foundation

public protocol TextAnnotationModelable {
  var text: String { get }
  var frame: CGRect { get }
  var fontName: String? { get }
  var fontSize: CGFloat? { get }
}

struct TextAnnotationAction: TextAnnotationModelable {
  let text: String
  let frame: CGRect
  let fontName: String?
  let fontSize: CGFloat?
}
