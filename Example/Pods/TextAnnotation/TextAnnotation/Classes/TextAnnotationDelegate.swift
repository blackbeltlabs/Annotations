import Foundation

public protocol TextAnnotationDelegate {
  func textAnnotationDidEdit(textAnnotation: TextAnnotation)
  func textAnnotationDidMove(textAnnotation: TextAnnotation)
}
