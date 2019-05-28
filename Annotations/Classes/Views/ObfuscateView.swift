import Foundation

protocol ObfuscateView: RectView {

}

extension ObfuscateView {
  static var modelType: CanvasItemType { return .obfuscate }
  
  static func createLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.obfuscate.cgColor
    layer.strokeColor = NSColor.obfuscate.cgColor
    layer.lineWidth = 0
    
    return layer
  }
}

class ObfuscateViewClass: RectViewClass, ObfuscateView {
  convenience init(state: RectViewState, modelIndex: Int) {
    let layer = type(of: self).createLayer()
    
    self.init(state: state, modelIndex: modelIndex, layer: layer)
  }
}
