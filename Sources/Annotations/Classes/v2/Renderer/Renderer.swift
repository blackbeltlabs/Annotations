import Cocoa

protocol RendererCanvas: AnyObject {
  func renderLayer(id: String,
                   type: LayerType,
                   path: CGPath,
                   settings: LayerUISettings,
                   zPosition: CGFloat)
  func renderText(text: Text)
}



class Renderer {
  weak var canvasView: RendererCanvas?
  
  
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
    
    let layerType = LayerTypeFactory.layerType(for: model)
    
    canvasView?.renderLayer(id: model.id,
                            type: layerType,
                            path: path,
                            settings: style,
                            zPosition: model.zPosition)
  }
  
  
  func renderText(_ model: Text) {
    
  }
}
