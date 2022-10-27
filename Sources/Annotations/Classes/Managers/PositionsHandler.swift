import Foundation

protocol PositionHandlerDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
}

// this class is intented to assign a correct zPosition
// for annotations that are created or interacted
final class PositionHandler {
  weak var dataSource: PositionHandlerDataSource?
  
  var maxZPosition: CGFloat {
    dataSource!
      .annotations
      .map(\.zPosition)
      .max() ?? 0
  }
  
  var newZPosition: CGFloat {
    return maxZPosition + 1
  }
  
  // no need to update for obfuscate and higlight tools as not supported now
  func makesSenseToUpdateZPosition(for model: AnnotationModel) -> Bool {
    if let rect = model as? Rect {
      if rect.rectType == .highlight || rect.rectType == .obfuscate {
        return false
      }
    }
    
    return true
  }
}
