import Foundation


struct LineDashPhaseAnimation: Selection {
  let id: String
  
  let lineDashPattern: [NSNumber]
  let fromValue: Int
  let toValue: Int
  let duration: Double
  let repeatCount: Float
  
  var animationKey: String {
    id
  }
  
  static func penAnimation(_ id: String) -> LineDashPhaseAnimation {
    let lineDashPattern: [NSNumber] = [10, 5, 5, 5].map { NSNumber(integerLiteral: $0) }
    
    return .init(id: id,
                 lineDashPattern: lineDashPattern,
                 fromValue: 0,
                 toValue: lineDashPattern.reduce(0) { $0 + $1.intValue },
                 duration: 1.5,
                 repeatCount: Float.greatestFiniteMagnitude)
  }
}

