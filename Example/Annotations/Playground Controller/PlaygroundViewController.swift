import Foundation
import AppKit
import Annotations

class PlaygroundViewController: NSViewController {
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  var modelsManager: ModelsManager?

  override func loadView() {
    loadViewClosure?(self)
  }
  
  let penMock = Pen.Mocks.mock

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
    
    
    modelsManager.add(models: [Arrow.Mocks.mock,
                               penMock,
                               Rect.Mocks.mockRegular,
                               Rect.Mocks.mockObfuscate,
                               Rect.Mocks.mockHighlight,
                               Rect.Mocks.mockHighlight2,
                               Rect.Mocks.mockHighlight3,
                               Rect.Mocks.mockRegularAsHighlight,
                               Number.Mocks.mock,
                               Text.Mocks.mockText1])
    
    
    
    let backgroundImage = NSImage(named: "catalina")!
    modelsManager.addBackgroundImage(backgroundImage)
    
    
    modelsManager.select(model: penMock)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      self.modelsManager?.deselect()
    }
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
  }
}


