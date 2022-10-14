import Foundation
import CoreGraphics
import Combine

protocol TextAnnotationsSource: AnyObject {
  func startEditingText(for id: String) -> AnyPublisher<String, Never>?
  
  func stopEditingText(for id: String)
}

class TextAnnotationsManager {
  var textStyle: TextParams = .defaultFont()
  
  weak var source: TextAnnotationsSource?
  
  private var editCancellable: AnyCancellable?
  
  private var startEditingString: String = ""
  private var editingText: Text?
  
  private var updatedTextAnnotationClosure: ((Text) -> Void)?
  
  
  private(set) var createMode: Bool = false
    
  
  static func createNewTextAnnotation(from point: CGPoint,
                                      color: ModelColor,
                                      zPosition: CGFloat,
                                      textStyle: TextParams) -> Text {
    
    let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: "",
                                                           attributes: textStyle.attributes)
    
    return Text(color: color,
                zPosition: zPosition,
                style: textStyle,
                legibilityEffectEnabled: false,
                text: "",
                origin: point.modelPoint,
                to: .init(x: point.x + bestSize.width,
                          y: point.y + bestSize.height))
  }
  
  
  func handleTextEditing(for text: Text, createMode: Bool = false, onUpdate: @escaping (Text) -> Void) {
    
    if createMode {
      self.createMode = createMode
    }
    
    editingText = text
    self.startEditingString = text.text
    editCancellable = source?.startEditingText(for: text.id)?.sink(receiveValue: { [weak self] textString in
      guard let self else { return }
      guard let editingText = self.editingText else { return }
      self.handleTextChanged(for: editingText, updatedString: textString)
      print("Text string received = \(textString)")
    })
    self.updatedTextAnnotationClosure = onUpdate
  }
  
  func updateEditingText(_ text: Text) {
    self.editingText = text
  }

  func cancelEditing() -> (model: Text?, textWasUpdated: Bool) {
    guard let editingId = editingText?.id else { return (nil, false) }
    if createMode {
      createMode = false
    }
    return cancelEditing(for: editingId)
  }
  
  func cancelEditing(for id: String) -> (model: Text?, textWasUpdated: Bool) {
    defer {
      updatedTextAnnotationClosure = nil
      editingText = nil
      startEditingString = ""
    }
    
    source?.stopEditingText(for: id)
    if let editingText {
      return (editingText, editingText.text != startEditingString)
    } else {
      return (nil, false)
    }
  }
  
  var isEditing: Bool {
    editingText != nil
  }
  
  
  func handleTextChanged(for text: Text, updatedString: String) {
    var updatedText = text
    let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: updatedString,
                                                           attributes: text.style.attributes)
    
    updatedText.text = updatedString
    updatedText.updateFrameSize(bestSize)
    
    self.editingText = updatedText
    
    updatedTextAnnotationClosure?(updatedText)
  }
}
