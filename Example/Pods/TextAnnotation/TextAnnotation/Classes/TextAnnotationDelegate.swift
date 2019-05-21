import Foundation

public protocol TextAnnotationDelegate {
  func textAnnotationDidSelect(textAnnotation: TextAnnotation)
  func textAnnotationDidEdit(textAnnotation: TextAnnotation)
  func textAnnotationDidMove(textAnnotation: TextAnnotation)
}
