import Foundation

public struct JSONNumberModel: Codable {
  public var id: String?
  public var color: ModelColor
  public var zPosition: CGFloat
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  public var number: Int
}
