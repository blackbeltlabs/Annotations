import Quartz
import Cocoa

struct HiglightRectArea: Equatable, Hashable, DrawableElement {
  var id: String
  let rect: CGRect
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
  
}

class HiglightsLayer: CALayer {
  private let maskLayer: CAShapeLayer = CAShapeLayer()
  
  private(set) var rectAreas: Set<HiglightRectArea> = [] {
    didSet {
      self.rerenderMasksPath(with: rectAreas.map(\.rect))
    }
  }
    
  override init() {
    super.init()
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setup() {
    self.mask = maskLayer
    maskLayer.fillRule = .evenOdd
    backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
  
  // MARK: - Obfuscated
  func addHighlightArea(path: CGPath, id: String) {
    let rect = path.boundingBox
    let area = HiglightRectArea(id: id, rect: rect)
    
    rectAreas.update(with: area)
  }
  
  func removeHighlightArea(_ id: String) {
    rectAreas.remove(.init(id: id, rect: .zero))
  }
  
  private func rerenderMasksPath(with rects: [CGRect]) {
    let maskPath = CGMutablePath()
    let bounds = bounds
    rects.forEach {
      maskPath.addPath(NSBezierPath.concaveRectPath(rect: $0, radius: 4))
    }
    maskPath.addRect(bounds)
    maskLayer.path = maskPath
  }

  var allHighlightDrawables: [DrawableElement] {
    Array(rectAreas)
  }
}
