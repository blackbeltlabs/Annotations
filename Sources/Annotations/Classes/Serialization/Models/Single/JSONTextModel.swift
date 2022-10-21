import Foundation

struct JSONTextModel: Codable {
    var id: String?
    var zPosition: CGFloat
    var origin: AnnotationPoint
    var text: String
    var style: TextParams
    var legibilityEffectEnabled: Bool
}
