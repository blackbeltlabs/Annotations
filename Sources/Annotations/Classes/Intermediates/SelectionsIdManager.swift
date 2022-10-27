import Foundation

enum SelectionIdType {
  case border
  case legibilityButton
  case emojiButton
}

// A manager that helps with the generation of unique id for selections (borders, emojis, buttons) of annotations
// to make it possible to identify them when updating or removal
class SelectionsIdManager {
  static func generateId(for type: SelectionIdType, of annotationId: String) -> String {
    switch type {
    case .border:
      return generateId(with: 10, appendTo: annotationId)
    case .legibilityButton:
      return generateId(with: 20, appendTo: annotationId)
    case .emojiButton:
      return generateId(with: 30, appendTo: annotationId)
    }
  }
  
  static func generateId(with number: Int, appendTo annotationId: String) -> String {
    String(format: "%@_%d", annotationId, number)
  }
  
  static func extractAnnotationIdFromNumberId(_ string: String) -> String? {
    string.components(separatedBy: "_").first
  }
}
