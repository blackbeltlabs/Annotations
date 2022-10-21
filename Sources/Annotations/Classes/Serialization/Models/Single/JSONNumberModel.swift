import Foundation

struct JSONNumberModel: Codable {
    var id: String?
    var color: ModelColor
    var zPosition: CGFloat
    var origin: AnnotationPoint
    var to: AnnotationPoint
    var number: Int
}
