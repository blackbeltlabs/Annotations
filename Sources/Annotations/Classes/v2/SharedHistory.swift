import Cocoa
import Combine

public class SharedHistory {
  private let manager = UndoManager()
  
  // MARK: - Combine
  private let canUndoSubject = CurrentValueSubject<Bool, Never>(false)
  private let canRedoSubject = CurrentValueSubject<Bool, Never>(false)
  
  private let undoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)
  private let redoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange)
  
  // MARK: - Publishers
  public var canUndoPublisher: AnyPublisher<Bool, Never> {
    canUndoSubject.eraseToAnyPublisher()
  }
  
  public var canRedoPublisher: AnyPublisher<Bool, Never> {
    canRedoSubject.eraseToAnyPublisher()
  }
  
  // MARK: - Cancellables
  private var cancellables = Set<AnyCancellable>()
  
  
  // MARK: - Init
  public init() {
    setupPublishers()
  }
  
  private func setupPublishers() {
    undoObserver
      .sink { [weak self] notification in
        guard let self else { return }
        self.updateUndoRedoStates()
      }
      .store(in: &cancellables)
    
    redoObserver
      .sink { [weak self] notification in
        guard let self else { return }
        self.updateUndoRedoStates()
      }
      .store(in: &cancellables)
  }
  
  private func updateUndoRedoStates() {
    canUndoSubject.send(manager.canUndo)
    canRedoSubject.send(manager.canRedo)
  }
  
  // MARK: - Add
  public func addUndo(closure: @escaping () -> Void) {
    manager.registerUndo(withTarget: self) { target in
      closure()
    }
    updateUndoRedoStates()
  }
  
  // MARK: - Perform
  public func performUndo() {
    manager.undo()
  }
  
  public func performRedo() {
    manager.redo()
  }
  
  // MARK: - Undo / Redo states
  public var canUndo: Bool {
    canUndoSubject.value
  }
  
  public var canRedo: Bool {
    canRedoSubject.value
  }
  
  // MARK: - Clear
  public func clear() {
    manager.removeAllActions()
  }
}
