import Foundation

private struct AnyDrawableModel: Hashable, Equatable {
  let model: DrawableElement
  
  static func == (lhs: AnyDrawableModel, rhs: AnyDrawableModel) -> Bool {
    let lhsID = lhs.model.id
    let rhsID = rhs.model.id
    return lhsID == rhsID
  }
  
  func hash(into hasher: inout Hasher) {
    let id = model.id
      
    hasher.combine(id)
  }
}


private struct StubModel: DrawableElement, Sendable {
  var id: String = ""
}

struct DrawableModelsSet {
  private var modelsSet: Set<AnyDrawableModel> = Set()
  
  var all: [DrawableElement] {
    modelsSet.map(\.model)
  }
  
  init(_ models: [DrawableElement]) {
    let anyModels = models.map { AnyDrawableModel(model: $0) }
    modelsSet = Set(anyModels)
  }
  
  mutating func refresh(with models: [DrawableElement]) {
    let anyModels = models.map { AnyDrawableModel(model: $0) }
    
    modelsSet = Set(anyModels)
  }
  
  mutating func update(_ model: DrawableElement) {
    let drawableModel = AnyDrawableModel(model: model)
    modelsSet.update(with: drawableModel)
  }
  
  func contains(_ model: DrawableElement) -> Bool {
    let drawableModel = AnyDrawableModel(model: model)
    return modelsSet.contains(drawableModel)
  }
  
  func contains(_ modelId: String) -> Bool {
    let empty = AnyDrawableModel(model: StubModel(id: modelId))
    return modelsSet.contains(empty)
  }
  
  func model(for id: String) -> DrawableElement? {
    let empty = AnyDrawableModel(model: StubModel(id: id))
    
    guard let index = modelsSet.firstIndex(of: empty) else { return nil }
    
    return modelsSet[index].model
  }
    
  mutating func remove(with id: String) {
    let empty = AnyDrawableModel(model: StubModel(id: id))
    modelsSet.remove(empty)
  }
  
  mutating func clearAll() {
    modelsSet.removeAll()
  }
}

