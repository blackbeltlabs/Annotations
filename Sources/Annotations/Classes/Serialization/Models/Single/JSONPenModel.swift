import Foundation

struct JSONPenModel: Codable {
    var id: String?
    var color: ModelColor
    var zPosition: CGFloat
    var points: [AnnotationPoint]
}
