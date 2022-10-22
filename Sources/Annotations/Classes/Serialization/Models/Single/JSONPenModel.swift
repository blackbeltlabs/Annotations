import Foundation

public struct JSONPenModel: Codable {
  public var id: String?
  public var color: ModelColor
  public var zPosition: CGFloat
  public var points: [AnnotationPoint]
}
