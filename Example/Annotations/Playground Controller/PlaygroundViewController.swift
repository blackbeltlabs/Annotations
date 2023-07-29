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
    imageView.imageScaling = .scaleAxesIndependently
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
    
    canvasView.layer?.backgroundColor = .clear
    
    

    annotationSettings.setObfuscateType(.imagePattern(image))

    
    setupPublishers(drawableCanvasView: canvasView)
    
    imageView.image = image
    
    mainView.viewLayoutClosure = { [weak self] in
      guard let self else { return }
      self.imageView.frame = .init(origin: .zero, size: self.mainView.frame.size)
    }
    
    parts.settings.textViewIsEditingPublisher.sink { result in
      print("Text view did editing = \(result)")
    }.store(in: &cancellables)
    
    do {
      let result = try JSONSerializer.deserializeFromFile(url: url)
      self.modelsManager.add(models: result.models)
    } catch let error {
      let alertController = NSAlert(error: error)
      alertController.runModal()
    }
    
    
    let newModels: [AnnotationModel] = [Arrow(color: .fuschia,
                                              zPosition: modelsManager.maxZPosition + 1,
                                              origin: .init(x: 0.0, y: 0.0),
                                              to: .init(x: 200, y: 200)),
                                        Rect(rectType: .obfuscate,
                                             origin: .init(x: 200.0, y: 200.0),
                                             to: .init(x: 600.0, y: 400.0))
                                        
    ]
    
    modelsManager.update(models: newModels, updateHistory: true)
    
    /* - Test delete multiple items
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      self.modelsManager.delete(models: newModels)
    }
     */
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
      .clearAllPressedPublisher
      .sink { [weak self] in
        self?.modelsManager.removeAll()
      }
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
      }
      .store(in: &cancellables)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    becomeFirstResponder()
    view.window?.makeKeyAndOrderFront(self)
  }
}

// MARK: - Previews
import SwiftUI

struct PlaygroundViewControllerPreview: NSViewControllerRepresentable {
  let image: NSImage
  let jsonURL: URL
  
  init(image: NSImage, jsonURL: URL) {
    self.image = image
    self.jsonURL = jsonURL
  }
  
  func makeNSViewController(context: Context) -> PlaygroundViewController {
    let wc = PlaygroundControllerAssembler.assemble(with: image, jsonURL: jsonURL, withControls: true)
    
    return wc.contentViewController as! PlaygroundViewController
  }

  func updateNSViewController(_ nsViewController: PlaygroundViewController, context: Context) {
  }
}


struct PlaygroundViewController_Previews: PreviewProvider {
  
  static let allJsonFiles: [String] = ["test_drawing.json",
                                       "test_drawing1.json",
                                       "test_drawing2.json"]
  static var previews: some View {
    Group {
      ForEach(allJsonFiles, id: \.self) { jsonFile in
        PlaygroundViewControllerPreview(image: NSImage(named: "catalina")!,
                                        jsonURL: Bundle.jsonURL(jsonFile))
        .border(.green, width: 1.0)
        .frame(width: 700,
               height: 500)
        .background(Color.clear)
        .padding()
      }
    }
  }
}
