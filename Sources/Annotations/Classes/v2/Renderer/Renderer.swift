import Cocoa

protocol RendererCanvas: AnyObject {
  func renderLayer(id: String,
                   type: LayerType,
                   path: CGPath,
                   settings: LayerUISettings,
                   zPosition: CGFloat)
  func renderText(text: Text)
}

enum LayerType {
  case normal
  case obfuscate
  case highlight
}

struct LayerUISettings {
  let lineWidth: CGFloat
  let strokeColor: CGColor?
  let fillColor: CGColor?
  let lineJoin: CAShapeLayerLineJoin
  let lineCap: CAShapeLayerLineCap
  let fillRule: CAShapeLayerFillRule
  let lineDash: (phase: CGFloat, lengths: [CGFloat]?)
  
  internal init(lineWidth: CGFloat,
                strokeColor: CGColor? = nil,
                fillColor: CGColor? = nil,
                lineJoin: CAShapeLayerLineJoin = .miter,
                lineCap: CAShapeLayerLineCap = .butt,
                fillRule: CAShapeLayerFillRule = .nonZero,
                lineDash: (phase: CGFloat, lengths: [CGFloat]?) = (0, nil)) {
    self.lineWidth = lineWidth
    self.strokeColor = strokeColor
    self.fillColor = fillColor
    self.lineJoin = lineJoin
    self.lineCap = lineCap
    self.fillRule = fillRule
    self.lineDash = lineDash
  }
  
}

class Renderer {
  weak var canvasView: NSView?
  
  
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
            
            
  }
  
  
  func renderText(_ model: Text) {
    
  }
}
