import Foundation
import AppKit

class PlaygroundViewController: NSViewController {
  
  var loadViewClosure: ((PlaygroundViewController) -> Void)?
  
  let simpleTextView: NSTextView = {
    let textView = NSTextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.string = "Test"
    
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.drawsBackground = false
    textView.isVerticallyResizable = true
  
    return textView
  }()
  
  
  override func loadView() {
    loadViewClosure?(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(simpleTextView)
    
    simpleTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
    simpleTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    simpleTextView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
    simpleTextView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    
    simpleTextView.wantsLayer = true
    simpleTextView.layer?.borderWidth = 1.0
  }
}
