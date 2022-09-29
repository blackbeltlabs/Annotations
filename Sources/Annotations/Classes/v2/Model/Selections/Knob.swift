import Foundation
import CoreGraphics

struct Knob: Selection {
  let id: String
  let frameRect: CGRect
  
  static let defaultSize = CGSize(width: 10, height: 10)
  
  static func fromCenterPoint(point: CGPoint, id: String = UUID().uuidString) -> Knob {
    let sizePart = self.defaultSize.width
    return .init(id: id, frameRect: .init(origin: .init(x: point.x - sizePart / 2.0,
                                                        y: point.y - sizePart / 2.0),
                                         size: defaultSize))
  }
  
  struct Mocks {
    static var rectKnobs: [Knob] {
      [.fromCenterPoint(point: .init(x: 20, y: 20)),
       .fromCenterPoint(point: .init(x: 100, y: 20)),
       .fromCenterPoint(point: .init(x: 100, y: 100)),
       .fromCenterPoint(point: .init(x: 20, y: 100))
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
