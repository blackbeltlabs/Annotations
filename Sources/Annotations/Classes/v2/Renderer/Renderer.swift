import Combine
import Cocoa


struct LayerRenderingSet {
  let path: CGPath
  let settings: LayerUISettings
  let zPosition: CGFloat
}


enum CursorType {
  case `default`
  case textEditing
  case textMove
  case textResize
  case textScale
}

protocol RendererCanvas: AnyObject {
  func renderLayer(id: String,
                   type: LayerType,
                   renderingSet: LayerRenderingSet)
  
  func renderText(text: Text, rendererType: TextRenderingType?)
  
  func startEditingText(for id: String) -> AnyPublisher<String, Never>?
  func stopEditingText(for id: String)
  
  func renderNumber(id: String,
                    renderingSet: LayerRenderingSet,
                    numberValue: Int,
                    numberFontSize: CGFloat)
  
  func renderObfuscatedAreaBackground(_ type: ObfuscatedAreaType)
  
  
  func renderSelections(_ selections: [Selection])
  func renderRemovalSelections(_ selections: [Selection])
  
  func renderLineDashPhaseAnimation(for layerId: String,
                                    animation: LineDashPhaseAnimation,
                                    remove: Bool)
  
  func renderRemoval(with id: String)
  
  func presentEmojiesPicker(for textId: String)
  
  
  func clearAll()
  
  func setCursor(for type: CursorType)
}

enum ObfuscatedAreaType {
  case solidColor(_ color: NSColor)
  case image(_ image: NSImage)
}

class Renderer: TextAnnotationsSource {
  weak var canvasView: RendererCanvas?
  
  init(canvasView: RendererCanvas?) {
    self.canvasView = canvasView
  }

  func render(_ models: [AnnotationModel]) {
     // canvasView?.clearAll()
    for model in models {
      render(.init(model: model, renderingType: nil))
    }
  }
  
  func render(_ renderedModel: RenderedModel) {
    let model = renderedModel.model
    
    if let text = model as? Text {
      renderText(text, rendererType: renderedModel.renderingType as? TextRenderingType)
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
        canvasView?.renderSelections(knobs.allKnobs)
      } else {
        canvasView?.renderSelections([])
      }
    } else if let pen = model as? Pen {
      canvasView?.renderLineDashPhaseAnimation(for: pen.id,
                                               animation: .penAnimation(pen.id),
                                               remove: !isSelected)
    } else if let text = model as? Text {
      if isSelected {
        
        guard let knobs = KnobsFactory.knobPair(for: model) else { return }
        
        canvasView?.renderSelections(knobs.allKnobs)
        
        let rect = TextBordersCreator.bordersRect(for: text)
        let lineWidth = TextBordersCreator.borderLineWidth(for: text)
        let border = Border.textAnnotationBorder(id: SelectionsIdManager.generateId(for: .border, of: text.id),
                                                 rect: rect,
                                                 lineWidth: lineWidth)
        
        let legibilityRect = TextBordersCreator.legibilityFrameRect(for: text)

        let legibilityControl = LegibilityControl(id: SelectionsIdManager.generateId(for: .legibilityButton,
                                                                                     of: text.id),
                                                  frameRect: legibilityRect,
                                                  isEnabled: text.legibilityEffectEnabled,
                                                  zPosition: 3)
        
        
        
        canvasView?.renderSelections([border, legibilityControl])
        
        
        let emojiControl = createEmojiControl(for: text)
        if text.displayEmojiPicker {
          canvasView?.renderSelections([emojiControl])
        } else {
          canvasView?.renderRemovalSelections([emojiControl])
        }
      } else {
        canvasView?.renderSelections([])
      }
    }
  }
  
  func createEmojiControl(for text: Text) -> EmojiControl {
    let legibilityRect = TextBordersCreator.legibilityFrameRect(for: text)
    let emojiButtonOriginX = legibilityRect.maxX + 5.0
    
    let emojiButtonRect = CGRect(x: emojiButtonOriginX,
                                 y: legibilityRect.origin.y,
                                 width: 23.0,
                                 height: 23.0)
    
    return EmojiControl(id: SelectionsIdManager.generateId(for: .emojiButton,
                                                           of: text.id),
                                                           frameRect: emojiButtonRect,
                                                           zPosition: 3)
  }

  // MARK: - Text annotation
  func renderText(_ model: Text, rendererType: TextRenderingType?) {
    canvasView?.renderText(text: model,
                           rendererType: rendererType)
    
    if rendererType == .newModel {
      renderSelection(for: model, isSelected: true)
    }
  }
  
  func renderTextEmojiPicker(for textId: String) {
    canvasView?.presentEmojiesPicker(for: textId)
  }
  
  func startEditingText(for text: Text,
                        options: TextAnnotationEditingOptions) -> AnyPublisher<String, Never>? {
    
    if options.showEmojiPickerButton {
      let control = createEmojiControl(for: text)
      canvasView?.renderSelections([control])
    }
    
    return canvasView?.startEditingText(for: text.id)
  }
  
  func stopEditingText(for text: Text) {
    canvasView?.stopEditingText(for: text.id)
    
    let control = createEmojiControl(for: text)
    canvasView?.renderRemovalSelections([control])
  }
  
  // MARK: - Cursors
  
  func setCursor(type: CursorType) {
    canvasView?.setCursor(for: type)
  }
  
  // MARK: - Obfuscated
  func renderObfuscatedAreaBackground(type: ObfuscatedAreaType) {
    canvasView?.renderObfuscatedAreaBackground(type)
  }
  
  // MARK: - Removal
  
  func renderRemoval(of modelId: String) {
    canvasView?.renderRemoval(with: modelId)
  }
}
