import Foundation

// can be used for arrows, rects, obfuscates, highlights
struct JSONOriginToModel: Codable {
    var id: String?
    var color: ModelColor
    var zPosition: CGFloat
    var origin: AnnotationPoint
    var to: AnnotationPoint
}
