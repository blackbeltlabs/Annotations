import Foundation

protocol ObfuscateCanvas: class, ObfuscateViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension ObfuscateCanvas {
  func redrawObfuscate(model: ObfuscateModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.obfuscates.firstIndex(of: model) else { return }
    let state = ObfuscateViewState(model: model, isSelected: false)
    let view = ObfuscateView(state: state,
                             modelIndex: modelIndex,
                             globalIndex: model.index,
                             color: model.color)
    view.delegate = self
    add(view)
  }
  
  func createObfuscateView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = ObfuscateModel(index: model.elements.count + 1,
                                 origin: origin,
                                 to: to,
                                 color: color)
    
    model.obfuscates.append(newRect)
    
    let state = ObfuscateViewState(model: newRect, isSelected: false)
    let newView = ObfuscateView(state: state,
                                modelIndex: model.obfuscates.count - 1,
                                globalIndex: newRect.index,
                                color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(obfuscate: ObfuscateView) -> CanvasModel {
    return model.copyWithout(type: .obfuscate, index: obfuscate.modelIndex)
  }
  
  func obfuscateView(_ view: ObfuscateView, didUpdate model: ObfuscateModel, atIndex index: Int) {
    self.model.obfuscates[index] = model
  }
  
  func fulfillLayerWithObfuscatePalette(layer: CALayer, colorsPalette: [NSColor]) {
    let widthPart: CGFloat = 10.0
    let bounds = layer.bounds
    
    var initialPoint: CGFloat = bounds.origin.x
    var initialYPoint: CGFloat = bounds.origin.y
    
    while initialYPoint <= bounds.height {
        
        while initialPoint <= bounds.width {
          let frame = CGRect(x: initialPoint,
                             y: initialYPoint,
                             width: widthPart,
                             height: widthPart)
          
          let shapeLayer = CAShapeLayer()
                      
          shapeLayer.path = CGPath(rect: frame, transform: nil)
          guard let cgColor = colorsPalette.randomElement()?.cgColor else { return }
          shapeLayer.fillColor = cgColor
          shapeLayer.strokeColor = nil
          
          layer.addSublayer(shapeLayer)
          
          initialPoint += widthPart
        }
        
        initialYPoint += widthPart
        initialPoint = 0
    }
  }
}
