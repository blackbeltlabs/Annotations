import Foundation

public protocol TextAnnotationDelegate {
  func textAnnotationDidSelect(textAnnotation: TextAnnotation)
  func textAnnotationDidDeselect(textAnnotation: TextAnnotation)
  func textAnnotationDidStartEditing(textAnnotation: TextAnnotation)
  func textAnnotationDidEndEditing(textAnnotation: TextAnnotation)
  func textAnnotationDidEdit(textAnnotation: TextAnnotation)
  func textAnnotationDidMove(textAnnotation: TextAnnotation)
}
