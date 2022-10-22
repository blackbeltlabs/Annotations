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
      if self.rectAreas.isEmpty {
        backgroundColor = .clear
      } else {
        backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.rerenderMasksPath(with: rectAreas.map(\.rect))
      }
    }
  }
  
  // MARK: - Init
  override init() {
    super.init()
    setup()
  }
  
  override init(layer: Any) {
    super.init(layer: layer)
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
      maskPath.addPath(CGPath.concaveRectPath(rect: $0, radius: 4))
    }
    maskPath.addRect(bounds)
    maskLayer.path = maskPath
  }

  var allHighlightDrawables: [DrawableElement] {
    Array(rectAreas)
  }
}


private extension CGPath {
  static func concaveRectPath(rect: CGRect, radius: CGFloat) -> CGPath {
    let cornerRadius = radius
      
    let path = CGMutablePath()
      
    let bottomLeft = CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius)
    path.move(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
    
    let bottomRight = CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius)
    path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      
    let topRight = CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius)
    path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      
    let topLeft = CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius)
    path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      
    return path
  }
}
