
import Foundation

public protocol TextAnnotationModelable {
  var text: String { get }
  var frame: CGRect { get }
  var textParams: TextParams { get }
}

struct TextAnnotationAction: TextAnnotationModelable {
  let text: String
  let frame: CGRect
  let textParams: TextParams
}
