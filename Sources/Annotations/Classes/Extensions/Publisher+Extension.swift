import Combine

extension Publisher where Failure == Never {
  // need this method to avoid resign cycle when assigning to self
  func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
    sink { [weak root] in
      root?[keyPath: keyPath] = $0
    }
  }
  
  // just empty sink if don't need to listen for values
  func sink() -> AnyCancellable {
    sink { _ in
      
    }
  }
}
