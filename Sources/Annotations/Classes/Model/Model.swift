import Foundation

public protocol Model: Codable, CustomStringConvertible, Equatable, Indexable {}

public protocol ShapeModel: Model {
  var id: String { get }
}

extension Model {
  var json: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let result = try! encoder.encode(self)
    return String(data: result, encoding: .utf8)!
  }
  
  public var description: String {
    return json
  }
}
