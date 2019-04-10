import Foundation

public protocol TextAnnotation {
  var text: String { get set }
  var frame: CGRect { get set }
}
