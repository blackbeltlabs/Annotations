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
  var editingText: Text?
  
  private var updatedTextAnnotationClosure: ((Text) -> Void)?
  
  
  func handleTextEditing(for text: Text, onUpdate: @escaping (Text) -> Void) {
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
  
  func cancelEditing() -> (model: Text?, textWasUpdated: Bool) {
    guard let editingId = editingText?.id else { return (nil, false) }
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
