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

  override func loadView() {
    loadViewClosure?(self)
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let (modelsManager, canvasView) = AnnotationsCanvasFactory.instantiate()
    
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
    
    canvasView.layer?.backgroundColor = NSColor.yellow.cgColor
    self.modelsManager = modelsManager
    
    let penMock = Pen.Mocks.mock
    let arrowMock = Arrow.Mocks.mock
    var rectRegular = Rect.Mocks.mockRegular
    let rectObfuscate = Rect.Mocks.mockObfuscate
    let rectHighlight = Rect.Mocks.mockHighlight
    let number = Number.Mocks.mock
    modelsManager.add(models: [arrowMock,
                               penMock,
                               rectRegular,
                               rectObfuscate,
                               rectHighlight,
                               Rect.Mocks.mockHighlight2,
                               Rect.Mocks.mockHighlight3,
                               Rect.Mocks.mockRegularAsHighlight,
                               number,
                               Text.Mocks.mockText1])
    
    
    let annotations: [AnnotationModel] = [penMock, arrowMock, rectRegular, rectObfuscate, rectHighlight, number]
    
    let annotations2: [AnnotationModel] = [rectRegular]
    
    let deltas = Array.init(repeating: 50, count: 10)

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
  
  func setupPublishers() {
    canvasControlsView
      .colorSelected
      .map(\.annotationModelColor)
      .assign(to: \.value, on: modelsManager.createColor)
      .store(in: &cancellables)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
  }
}


