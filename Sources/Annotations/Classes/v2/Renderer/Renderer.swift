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
  var lineWidth: CGColor
  var strokeColor: CGColor?
  var fillColor: CGColor?
  var joinStyle: CAShapeLayerLineJoin
  var capStyle: CAShapeLayerLineCap
  var fillRule: CAShapeLayerFillRule
  var lineDash: (phase: CGFloat?, lengths: [CGFloat]?)?
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
    guard let path = PathCreatorFactory.path(for: model) else {
      fatalError("Can`t instantiate path for model")
    }
  
  }
  
  
  func renderText(_ model: Text) {
    
  }
}
