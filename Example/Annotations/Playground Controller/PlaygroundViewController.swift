import Foundation
import AppKit
import Annotations
import Combine

class PlaygroundViewController: NSViewController {
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  var modelsManager: ModelsManager?

  override func loadView() {
    loadViewClosure?(self)
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let (modelsManager, canvasView) = AnnotationsCanvasFactory.instantiate()
    
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(canvasView)
    
    canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    canvasView.layer?.backgroundColor = NSColor.yellow.cgColor
    self.modelsManager = modelsManager
    
    let penMock = Pen.Mocks.mock
    let arrowMock = Arrow.Mocks.mock
    let rectRegular = Rect.Mocks.mockRegular
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
    
    
    annotations
      .publisher
      .flatMap(maxPublishers: .max(1)) { Just($0).delay(for: 2.0, scheduler: RunLoop.main) }
      .sink { [weak self] model in
        print("Select model = \(model)")
        
        let updatedModel = Movement.movedAnnotation(model, delta: .init(dx: 20, dy: 20))
        
        self?.modelsManager?.update(model: updatedModel)
        
       // self?.modelsManager?.select(model: updatedModel)
      }
      .store(in: &cancellables)
    
    let backgroundImage = NSImage(named: "catalina")!
    modelsManager.addBackgroundImage(backgroundImage)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
  }
}


