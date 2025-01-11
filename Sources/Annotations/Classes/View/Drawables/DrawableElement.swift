import Foundation


protocol DrawableElement: Sendable {
  @MainActor
  var id: String { get set }
  
  nonisolated var uniqueId: String { get }
}

extension DrawableElement {
  nonisolated var uniqueId: String {
    MainActor.assumeIsolated {
      id
    }
  }
}
