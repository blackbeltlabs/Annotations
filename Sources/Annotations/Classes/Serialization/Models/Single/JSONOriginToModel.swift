import Foundation

// can be used for arrows, rects, obfuscates, highlights
public struct JSONOriginToModel: Codable {
  public var id: String?
  public var color: ModelColor
  public var zPosition: CGFloat
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
}
