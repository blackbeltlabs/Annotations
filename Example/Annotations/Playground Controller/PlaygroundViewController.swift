import Foundation
import AppKit
import Annotations

class PlaygroundViewController: NSViewController {
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  let simpleTextView: NSTextView = {
    let textView = NSTextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.string = "Test"
    return textView
  }()
  
  let textView: TestTextView = {
    let textView = TestTextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.string = "Our Text View"
    return textView
  }()
  
  
  override func loadView() {
    loadViewClosure?(self)
  }
  
  private func setupTextView(_ textView: NSTextView) {
    
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.drawsBackground = false
    textView.isVerticallyResizable = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(simpleTextView)
    
    view.addSubview(textView)
    
    setupTextView(simpleTextView)
    setupTextView(textView)
    
    simpleTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
    simpleTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    simpleTextView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
    simpleTextView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    
    simpleTextView.wantsLayer = true
    simpleTextView.layer?.borderWidth = 1.0
    
    
    textView.topAnchor.constraint(equalTo: simpleTextView.bottomAnchor, constant: 20.0).isActive = true
    textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    
    textView.wantsLayer = true
    textView.layer?.borderWidth = 1.0
  }
}



