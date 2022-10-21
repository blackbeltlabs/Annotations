import Foundation

public struct SortedDataDeserializationResult {
  public let models: [AnnotationModel]
  public let commonStyle: TextParams
}

final class JSONModelsConverter {
  
  private init() { }
  
  // MARK: - SortedModel
  static func convertSortedModel(_ model: JSONSortedModel) -> SortedDataDeserializationResult {
    let annotationModels: [AnnotationModel] =
    model.arrows.map { convertToArrowModel(jsonModel: $0) } +
    model.pens.map { convertToPenModel(jsonModel: $0) } +
    model.rects.map { convertToRectModel(jsonModel: $0, rectType: .regular) } +
    model.obfuscates.map { convertToRectModel(jsonModel: $0, rectType: .obfuscate) } +
    model.highlights.map { convertToRectModel(jsonModel: $0, rectType: .highlight) } +
    model.numbers.map { convertToNumberModel(jsonModel: $0) } +
    model.texts.map { convertToTextModel(jsonModel: $0, commonStyle: model.style) }
    
    return .init(models: annotationModels, commonStyle: model.style)
  }
  
  // MARK: - Single models
  static func convertToRectModel(jsonModel: JSONOriginToModel, rectType: RectModelType) -> Rect {
    .init(rectType: rectType,
          id: jsonModel.id ?? randomId(),
          color: jsonModel.color,
          zPosition: jsonModel.zPosition,
          origin: jsonModel.origin,
          to: jsonModel.to)
  }
  
  static func convertToArrowModel(jsonModel: JSONOriginToModel) -> Arrow {
    .init(id: jsonModel.id ?? randomId(),
          color: jsonModel.color,
          zPosition: jsonModel.zPosition,
          origin: jsonModel.origin,
          to: jsonModel.to)
  }
  
  static func convertToNumberModel(jsonModel: JSONNumberModel) -> Number {
    .init(id: jsonModel.id ?? randomId(),
          color: jsonModel.color,
          zPosition: jsonModel.zPosition,
          origin: jsonModel.origin,
          to: jsonModel.to,
          value: jsonModel.number)
  }
  
  static func convertToPenModel(jsonModel: JSONPenModel) -> Pen {
    .init(id: jsonModel.id ?? randomId(),
          color: jsonModel.color,
          zPosition: jsonModel.zPosition,
          points: jsonModel.points)
  }
  
  static func convertToTextModel(jsonModel: JSONTextModel, commonStyle: TextParams) -> Text {
    
    let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: jsonModel.text,
                                                           attributes: jsonModel.style.attributes)
    
    let toOrigin = CGPoint(x: jsonModel.origin.x + bestSize.width,
                           y: jsonModel.origin.y + bestSize.height)
    
    let finalStyle = jsonModel.style.updatedModelWithTextParamsIfNil(commonStyle)
    
    
    return .init(id: jsonModel.id ?? randomId(),
                 zPosition: jsonModel.zPosition,
                 style: finalStyle,
                 legibilityEffectEnabled: jsonModel.legibilityEffectEnabled,
                 text: jsonModel.text,
                 origin: jsonModel.origin,
                 to: toOrigin.modelPoint,
                 displayEmojiPicker: false)
  }
  
  // MARK: - Helpers
  private static func randomId() -> String {
    UUID().uuidString
  }
}
