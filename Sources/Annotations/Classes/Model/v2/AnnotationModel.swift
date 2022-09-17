import CoreGraphics

public protocol AnnotationModel: Identifiable, Codable {
  var id: String { get set }
  var colour: ModelColor { get set }
  var zPosition: CGFloat { get set }
  
  var points: [AnnotationPoint] { get set }
}

public protocol TwoPointsModel {
  var origin: AnnotationPoint { get set }
  var to: AnnotationPoint { get set }
}

extension TwoPointsModel {
  public var points: [AnnotationPoint] {
    get {
      [origin, to]
    }
    
    set {
      guard newValue.count >= 2 else { return }
      origin = newValue[0]
      to = newValue[1]
    }
  }
}
