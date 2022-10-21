import Foundation
import AppKit
import Annotations
import Combine

enum LocalError: LocalizedError {
  case cantLoadFromBundle(_ name: String, _ ext: String)
  
  var errorDescription: String? {
    switch self {
    case .cantLoadFromBundle(let name, let ext):
      return "Can't create url from bundle from \(name).\(ext)"
    }
  }
}

class PlaygroundViewController: NSViewController {
  
  let imageView: NSImageView = {
    let imageView = NSImageView(frame: .zero)
    imageView.imageScaling = .scaleNone
    return imageView
  }()
  
  let canvasControlsView: CanvasControlsView = {
    let view = CanvasControlsView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  var parts: AnnotationsManagingParts!
  
  var modelsManager: ModelsManager {
    parts.modelsManager
  }
  
  var sharedHistory: SharedHistory {
    parts.history
  }
  
  var annotationSettings: Annotations.Settings {
    parts.settings
  }
  
  let image: NSImage
  let url: URL
  let withControls: Bool
  
  init(image: NSImage, url: URL, withControls: Bool) {
    self.url = url
    self.image = image
    self.withControls = withControls
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    loadViewClosure?(self)
  }
  
  var mainView: MainView {
    view as! MainView
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(imageView)
    
    let (canvasView, parts) = AnnotationsCanvasFactory.instantiate()
    self.parts = parts
    
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(canvasView)
    
    view.addSubview(canvasControlsView)
    
    canvasControlsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    canvasControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    canvasControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    canvasControlsView.heightAnchor.constraint(equalToConstant: 65.0).isActive = true
    
    canvasControlsView.isHidden = !withControls
    
    canvasView.topAnchor.constraint(equalTo: withControls ? canvasControlsView.bottomAnchor : view.topAnchor).isActive = true
    canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    canvasView.layer?.backgroundColor = .clear // NSColor.brown.cgColor
    
        
    annotationSettings.setBackgroundImage(image)
    
    setupPublishers(drawableCanvasView: canvasView)
    
    imageView.image = image
    
    mainView.viewLayoutClosure = { [weak self] in
      guard let self else { return }
      self.imageView.frame = .init(origin: .zero, size: self.mainView.frame.size)
    }
    
    do {
      let result = try JSONSerializer.deserializeFromFile(url: url)
      self.modelsManager.add(models: result.models)
    } catch let error {
      let alertController = NSAlert(error: error)
      alertController.runModal()
    }
  }

  
 // do not call super here otherwise beep sound will be played
  override func keyDown(with event: NSEvent) {
    // delete button {
    if event.keyCode == 51  {
      modelsManager.deleteSelectedModel()
    }
  }
  
  override var acceptsFirstResponder: Bool { true }
  
  func setupPublishers(drawableCanvasView: DrawableCanvasView) {
    canvasControlsView
      .colorSelected
      .map(\.annotationModelColor)
      .assign(to: \.value, on: annotationSettings.createColorSubject)
      .store(in: &cancellables)
    
    canvasControlsView
      .canvasAnnotationType
      .map(\.createMode)
      .assign(to: \.value, on: annotationSettings.currentAnnotationTypeSubject)
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
    
    
    parts.settings
      .textViewIsEditingPublisher
      .sink { [weak self] isEditing in
        guard let self else { return }
        if !isEditing {
          self.view.window?.makeFirstResponder(self.view)
        }
      }.store(in: &cancellables)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    becomeFirstResponder()
    view.window?.makeKeyAndOrderFront(self)
    
    /*
    let penMock = Pen.Mocks.mock
    let arrowMock = Arrow.Mocks.mock
    var rectRegular = Rect.Mocks.mockRegular
    let rectObfuscate = Rect.Mocks.mockObfuscate
    let rectHighlight = Rect.Mocks.mockHighlight
    let number = Number.Mocks.mock
    var textModel = Text.Mocks.mockText1
    
    modelsManager.add(models: [arrowMock,
                               penMock,
                               rectRegular,
                               rectObfuscate,
                               rectHighlight,
                               Rect.Mocks.mockHighlight2,
                               Rect.Mocks.mockHighlight3,
                               Rect.Mocks.mockRegularAsHighlight,
                               number])
     */
    
    
   
  }
}

import SwiftUI

struct PlaygroundViewControllerPreview: NSViewControllerRepresentable {
  let image: NSImage
  let jsonURL: URL
  
  init(image: NSImage, jsonURL: URL) {
    self.image = image
    self.jsonURL = jsonURL
  }
  
  func makeNSViewController(context: Context) -> PlaygroundViewController {
    let wc = PlaygroundControllerAssembler.assemble(with: image, jsonURL: jsonURL, withControls: false)
    
    return wc.contentViewController as! PlaygroundViewController
  }

  func updateNSViewController(_ nsViewController: PlaygroundViewController, context: Context) {
  }
}


struct PlaygroundViewController_Previews: PreviewProvider {
    static var previews: some View {
      PlaygroundViewControllerPreview(image: NSImage(named: "catalina")!,
                                      jsonURL: Bundle.jsonURL("test_drawing.json"))
        .border(.green, width: 1.0)
        .frame(width: 700,
                 height: 500)
        .background(Color.clear)
        .padding()
    }
}
