import Foundation

public struct JSONTextModel: Codable {
  public var id: String?
  public var zPosition: CGFloat
  public var origin: AnnotationPoint
  public var to: AnnotationPoint?
  public var text: String
  public var style: TextParams
  public var legibilityEffectEnabled: Bool
}
