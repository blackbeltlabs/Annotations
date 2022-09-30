import Cocoa

struct LayerRenderingSet {
  let path: CGPath
  let settings: LayerUISettings
  let zPosition: CGFloat
}


protocol RendererCanvas: AnyObject {
  func renderLayer(id: String,
                   type: LayerType,
                   renderingSet: LayerRenderingSet)
  func renderText(text: Text)
  
  func renderNumber(id: String,
                    renderingSet: LayerRenderingSet,
                    numberValue: Int,
                    numberFontSize: CGFloat)
  
  func renderObfuscatedAreaBackground(_ type: ObfuscatedAreaType)
  
  
  func renderKnobs(_ knobs: [Knob])
  
  func renderLineDashPhaseAnimation(for layerId: String,
                                    animation: LineDashPhaseAnimation,
                                    remove: Bool)
}

enum ObfuscatedAreaType {
  case solidColor(_ color: NSColor)
  case image(_ image: NSImage)
}

class Renderer {
  weak var canvasView: RendererCanvas?
  
  init(canvasView: RendererCanvas?) {
    self.canvasView = canvasView
  }
  
  func render(_ models: [AnnotationModel]) {
    for model in models {
      render(model)
    }
  }
  
  func render(_ model: AnnotationModel) {
    if let text = model as? Text {
      renderText(text)
    } else if let figure = model as? Figure {
      renderFigure(figure)
    }
  }
  
  func renderFigure(_ model: Figure) {
    guard let path = PathFactory.path(for: model) else {
      fatalError("Can`t instantiate path for model = \(model)")
    }
    
    guard let style = FigureStyleFactory.figureStyle(for: model) else {
      fatalError("Can't instantiate style for model = \(model)")
    }
    
    let renderingSet: LayerRenderingSet = .init(path: path,
                                                settings: style,
                                                zPosition: model.zPosition)
    switch model {
    case let number as Number:
      canvasView?.renderNumber(id: number.id,
                               renderingSet: renderingSet,
                               numberValue: number.value,
                               numberFontSize: number.size.height * 0.6)
    default:
      let layerType = LayerTypeFactory.layerType(for: model)
      
      canvasView?.renderLayer(id: model.id,
                              type: layerType,
                              renderingSet: renderingSet)
    }
  }
  
  func renderSelection(for model: AnnotationModel, isSelected: Bool) {
    if model is Rect || model is Arrow || model is Number {
      if isSelected {
        guard let knobs = KnobsFactory.knobPair(for: model) else { return }
        canvasView?.renderKnobs(knobs.allKnobs)
      } else {
        canvasView?.renderKnobs([])
      }
    } else if let pen = model as? Pen {
      canvasView?.renderLineDashPhaseAnimation(for: pen.id,
                                               animation: .penAnimation(pen.id),
                                               remove: !isSelected)
    }
  }
  
  
  func renderText(_ model: Text) {
    canvasView?.renderText(text: model)
  }
  
  func renderObfuscatedAreaBackground(type: ObfuscatedAreaType) {
    canvasView?.renderObfuscatedAreaBackground(type)
  }
}
