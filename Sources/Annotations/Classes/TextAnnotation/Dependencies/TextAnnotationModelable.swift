
import Foundation

public protocol TextAnnotationModelable {
  var text: String { get }
  var frame: CGRect { get }
  var style: TextParams { get }
  var legibilityEffectEnabled: Bool { get }
}

struct TextAnnotationAction: TextAnnotationModelable {
  let text: String
  let frame: CGRect
  let style: TextParams
  let legibilityEffectEnabled: Bool
}
