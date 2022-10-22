import Foundation

public struct JSONSortedModel: Codable {
  public var style: TextParams
  public var texts: [JSONTextModel]
  public var arrows: [JSONOriginToModel]
  public var pens: [JSONPenModel]
  public var rects: [JSONOriginToModel]
  public var obfuscates: [JSONOriginToModel]
  public var highlights: [JSONOriginToModel]
  public var numbers: [JSONNumberModel]
}
