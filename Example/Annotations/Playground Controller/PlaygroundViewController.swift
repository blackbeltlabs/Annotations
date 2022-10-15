import Foundation
import AppKit
import Annotations
import Combine

class PlaygroundViewController: NSViewController {
  
  let canvasControlsView: CanvasControlsView = {
    let view = CanvasControlsView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  var modelsManager: ModelsManager!
  
  var sharedHistory: SharedHistory!

  override func loadView() {
    loadViewClosure?(self)
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let (modelsManager, canvasView, history) = AnnotationsCanvasFactory.instantiate()
    
    sharedHistory = history
    
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(canvasView)
    
    view.addSubview(canvasControlsView)
    
    canvasControlsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    canvasControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    canvasControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    canvasControlsView.heightAnchor.constraint(equalToConstant: 65.0).isActive = true
    
    canvasView.topAnchor.constraint(equalTo: canvasControlsView.bottomAnchor).isActive = true
    canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    canvasView.layer?.backgroundColor = NSColor.brown.cgColor
    self.modelsManager = modelsManager
    
    let penMock = Pen.Mocks.mock
    let arrowMock = Arrow.Mocks.mock
    var rectRegular = Rect.Mocks.mockRegular
    let rectObfuscate = Rect.Mocks.mockObfuscate
    let rectHighlight = Rect.Mocks.mockHighlight
    let number = Number.Mocks.mock
    var textModel = Text.Mocks.mockText1
    modelsManager.add(models: [/*arrowMock,
                               penMock,
                               rectRegular,
                               rectObfuscate,
                               rectHighlight,
                               Rect.Mocks.mockHighlight2,
                               Rect.Mocks.mockHighlight3,
                               Rect.Mocks.mockRegularAsHighlight,
                               number, */
                               textModel])
    
    
    let annotations: [AnnotationModel] = [penMock, arrowMock, rectRegular, rectObfuscate, rectHighlight, number]
    
    let annotations2: [AnnotationModel] = [rectRegular]
    
    let deltas = Array.init(repeating: 50, count: 10)
    
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//      textModel.legibilityEffectEnabled = true
//      self.modelsManager.update(model: textModel)
//    }

    /*
    deltas
      .publisher
      .flatMap(maxPublishers: .max(1)) { Just($0).delay(for: 2.0, scheduler: RunLoop.main) }
      .sink { [weak self] delta in
        
  
        let rect = ResizeTransformationFactory.resizedAnnotation(annotation: rectRegular, knob: RectKnobType.topRight, delta: .init(dx: delta, dy: 0))
        
        rectRegular = rect as! Rect
        
        self?.modelsManager?.update(model: rect)
        
        
        self?.modelsManager?.select(model: rect)
        
       // self?.modelsManager?.select(model: model)
      }
      .store(in: &cancellables)
    */
     
    let backgroundImage = NSImage(named: "catalina")!
    modelsManager.addBackgroundImage(backgroundImage)
    
    setupPublishers()
    
  }
  

  override func keyDown(with event: NSEvent) {
    super.keyDown(with: event)
    
    // delete button {
    if event.keyCode == 51  {
      modelsManager.deleteSelectedModel()
    }
  }
  
  override var acceptsFirstResponder: Bool { true }
  
  func setupPublishers() {
    canvasControlsView
      .colorSelected
      .map(\.annotationModelColor)
      .assign(to: \.value, on: modelsManager.createColorSubject)
      .store(in: &cancellables)
    
    canvasControlsView
      .canvasAnnotationType
      .map(\.createMode)
      .assign(to: \.value, on: modelsManager.createModeSubject)
      .store(in: &cancellables)
    
    canvasControlsView
      .undoPressedPublisher
      .sink { [weak self] in
        self?.sharedHistory.performUndo()
      }
      .store(in: &cancellables)
    
    canvasControlsView
      .redoPressedPublisher
      .sink { [weak self] in
        self?.sharedHistory.performRedo()
      }
      .store(in: &cancellables)
    
    sharedHistory
      .canUndoPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: \.isEnabled, on: canvasControlsView.undoButton)
      .store(in: &cancellables)
    
    sharedHistory
      .canRedoPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: \.isEnabled, on: canvasControlsView.redoButton)
      .store(in: &cancellables)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    becomeFirstResponder()
    view.window?.makeKeyAndOrderFront(self)
  }
}


