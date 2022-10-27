import Foundation
import CoreGraphics

struct Knob: Selection {
  let id: String
  let frameRect: CGRect
  let borderColor: CGColor
  let backgroundColor: CGColor
  

  static let defaultSize = CGSize(width: 10, height: 10)
  
  static func fromCenterPoint(point: CGPoint,
                              sizePart: CGFloat = Self.defaultSize.width,
                              id: String,
                              borderColor: CGColor = .commonKnobBorderColor,
                              backgroundColor: CGColor = .zapierOrange) -> Knob {
    return .init(id: id,
                 frameRect: .init(origin: .init(x: point.x - sizePart / 2.0,
                                                y: point.y - sizePart / 2.0),
                                  size: .init(width: sizePart, height: sizePart)),
                 borderColor: borderColor,
                 backgroundColor: backgroundColor)
  }
  
  struct Mocks {
    static var rectKnobs: [Knob] {
      [.fromCenterPoint(point: .init(x: 20, y: 20), id: UUID().uuidString),
       .fromCenterPoint(point: .init(x: 100, y: 20), id: UUID().uuidString),
       .fromCenterPoint(point: .init(x: 100, y: 100), id: UUID().uuidString),
       .fromCenterPoint(point: .init(x: 20, y: 100), id: UUID().uuidString)
      ]
    }
  }
}

extension Knob: Hashable, Equatable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
