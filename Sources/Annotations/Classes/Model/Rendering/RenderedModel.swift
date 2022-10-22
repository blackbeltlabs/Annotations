import Foundation

protocol RenderingType {
  
}

enum CommonRenderingType: RenderingType {
  case dontRenderSelection
}

enum TextRenderingType: RenderingType {
  case newModel
  case resize
  case scale
  case textEditingUpdate
}

struct RenderedModel {
  let model: AnnotationModel
  let renderingType: RenderingType?
  
  var id: String { model.id }
}
