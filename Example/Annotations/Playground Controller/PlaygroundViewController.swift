import Foundation
import AppKit
import Annotations

class PlaygroundViewController: NSViewController {
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  var modelsManager: ModelsManager?

  override func loadView() {
    loadViewClosure?(self)
  }

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
                               Pen.Mocks.mock,
                               Rect.Mocks.mockRegular,
                               Rect.Mocks.mockObfuscate,
                               Number.Mocks.mock,])
  }
}


