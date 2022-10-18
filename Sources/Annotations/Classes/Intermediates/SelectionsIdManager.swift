import Foundation

enum SelectionIdType {
  case border
  case legibilityButton
  case emojiButton
}

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
