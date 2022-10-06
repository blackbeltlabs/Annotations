import Foundation

private struct AnyAnnotationModel: Hashable, Equatable {
  let model: AnnotationModel
  
  static func == (lhs: AnyAnnotationModel, rhs: AnyAnnotationModel) -> Bool {
    lhs.model.id == rhs.model.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(model.id)
  }
}

private struct StubModel: AnnotationModel {
  var id: String
  
  var color: ModelColor = .defaultColor()
  
  var zPosition: CGFloat = 0
  
  var points: [AnnotationPoint] = []
}

struct AnnotationModelsSet {
  private var modelsSet: Set<AnyAnnotationModel> = Set()
  
  var all: [AnnotationModel] {
    modelsSet.map(\.model)
  }
  
  init(_ models: [AnnotationModel]) {
    let anyModels = models.map { AnyAnnotationModel(model: $0) }
    modelsSet = Set(anyModels)
  }
  
  mutating func refresh(with models: [AnnotationModel]) {
    let anyModels = models.map { AnyAnnotationModel(model: $0) }
    
    modelsSet = Set(anyModels)
  }
  
  mutating func update(_ model: AnnotationModel) {
    let annotationModel = AnyAnnotationModel(model: model)
    modelsSet.update(with: annotationModel)
  }
  
  func contains(_ model: AnnotationModel) -> Bool {
    let annotationModel = AnyAnnotationModel(model: model)
    return modelsSet.contains(annotationModel)
  }
  
  func contains(_ modelId: String) -> Bool {
    let empty = AnyAnnotationModel(model: StubModel(id: modelId))
    return modelsSet.contains(empty)
  }
  
  func model(for id: String) -> AnnotationModel? {
    let empty = AnyAnnotationModel(model: StubModel(id: id))
    
    guard let index = modelsSet.firstIndex(of: empty) else { return nil }
    
    return modelsSet[index].model
  }
  
  mutating func remove(with id: String) {
    let empty = AnyAnnotationModel(model: StubModel(id: id))
    modelsSet.remove(empty)
  }
}
