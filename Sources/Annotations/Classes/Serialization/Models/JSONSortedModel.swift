import Foundation

struct JSONSortedModel: Codable {
    var style: TextParams
    var texts: [JSONTextModel]
    var arrows: [JSONOriginToModel]
    var pens: [JSONPenModel]
    var rects: [JSONOriginToModel]
    var obfuscates: [JSONOriginToModel]
    var highlights: [JSONOriginToModel]
    var numbers: [JSONNumberModel]
}
