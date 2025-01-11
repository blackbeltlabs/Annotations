import Foundation

public struct SortedDataDeserializationResult: Sendable {
  public let models: [AnnotationModel]
  public let commonStyle: TextParams
}

final class JSONModelsConverter {
  
  private init() { }
  
  // MARK: - SortedModel
  static func convertFromSortedModel(_ model: JSONSortedModel) -> SortedDataDeserializationResult {
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
  
  static func convertToSortedModel(_ annotations: [AnnotationModel]) -> JSONSortedModel {
    let rects = annotations.compactMap { model in
      guard let rect = model as? Rect else { return nil }
      return rect.rectType == .regular ? rect : nil
    }.map { toJSONOriginTo($0)  }
    
    let obfuscates = annotations.compactMap { model in
      guard let rect = model as? Rect else { return nil }
      return rect.rectType == .obfuscate ? rect : nil
    }.map { toJSONOriginTo($0)  }
    
    let highlights = annotations.compactMap { model in
      guard let rect = model as? Rect else { return nil }
      return rect.rectType == .highlight ? rect : nil
    }.map { toJSONOriginTo($0)  }
    
    return JSONSortedModel(style: .empty(),
                           texts: annotations.compactMap { $0 as? Text }.map { toJSONText($0) },
                           arrows: annotations.compactMap { $0 as? Arrow }.map { toJSONOriginTo($0) },
                           pens: annotations.compactMap { $0 as? Pen }.map { toJSONPen($0) },
                           rects: rects,
                           obfuscates: obfuscates,
                           highlights: highlights,
                           numbers: annotations.compactMap { $0 as? Number }.map { toJSONNumber($0) })
  }
  
  // MARK: - JSON to Models
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
    
    let finalStyle = jsonModel.style.updatedModelWithTextParamsIfNil(commonStyle)
    
    let toOrigin: AnnotationPoint = {
      if let toOrigin = jsonModel.to {
        return toOrigin
      } else {
        let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: jsonModel.text,
                                                               attributes: finalStyle.attributes)
        
        let toOrigin = CGPoint(x: jsonModel.origin.x + bestSize.width,
                               y: jsonModel.origin.y + bestSize.height)
        return toOrigin.modelPoint
      }
    }()
    
    return .init(id: jsonModel.id ?? randomId(),
                 zPosition: jsonModel.zPosition,
                 style: finalStyle,
                 legibilityEffectEnabled: jsonModel.legibilityEffectEnabled,
                 text: jsonModel.text,
                 origin: jsonModel.origin,
                 to: toOrigin,
                 displayEmojiPicker: false)
  }
  
  // MARK: - Models to JSON
  
  static func toJSONOriginTo(_ twoPointsModel: TwoPointsModel) -> JSONOriginToModel {
    .init(id: twoPointsModel.id,
          color: twoPointsModel.color,
          zPosition: twoPointsModel.zPosition,
          origin: twoPointsModel.origin,
          to: twoPointsModel.to)
  }
  
  static func toJSONNumber(_ number: Number) -> JSONNumberModel {
    .init(id: number.id,
          color: number.color,
          zPosition: number.zPosition,
          origin: number.origin,
          to: number.to,
          number: number.value)
  }
  
  static func toJSONPen(_ pen: Pen) -> JSONPenModel {
    .init(id: pen.id,
          color: pen.color,
          zPosition: pen.zPosition,
          points: pen.points)
  }
  
  static func toJSONText(_ text: Text) -> JSONTextModel {
    .init(id: text.id,
          zPosition: text.zPosition,
          origin: text.origin,
          to: text.to,
          text: text.text,
          style: text.style,
          legibilityEffectEnabled: text.legibilityEffectEnabled)
  }
  
  
  
  
  // MARK: - Helpers
  private static func randomId() -> String {
    UUID().uuidString
  }
}
