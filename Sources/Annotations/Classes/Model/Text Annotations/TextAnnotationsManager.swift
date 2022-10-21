import Foundation
import CoreGraphics
import Combine

struct TextAnnotationEditingOptions {
  let showEmojiPickerButton: Bool
}

protocol TextAnnotationsSource: AnyObject {
  func startEditingText(for text: Text,
                        options: TextAnnotationEditingOptions) -> AnyPublisher<String, Never>?
  func stopEditingText(for text: Text)
}

class TextAnnotationsManager {
  var textStyle: TextParams = .defaultFont()
  
  weak var source: TextAnnotationsSource?
  
  private var editCancellable: AnyCancellable?
  
  private var startEditingString: String = ""
  private(set) var editingText: Text?
  
  private var updatedTextAnnotationClosure: ((Text) -> Void)?
  
  
  private(set) var createMode: Bool = false
    
  
  static func createNewTextAnnotation(from point: CGPoint,
                                      color: ModelColor,
                                      zPosition: CGFloat,
                                      textStyle: TextParams) -> Text {
    
    let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: "",
                                                           attributes: textStyle.attributes)
    let updatedStyle = textStyle.updatedWithColor(color)
    
    return Text(zPosition: zPosition,
                style: updatedStyle,
                legibilityEffectEnabled: false,
                text: "",
                origin: point.modelPoint,
                to: .init(x: point.x + bestSize.width,
                          y: point.y + bestSize.height))
  }
  
  
  func handleTextEditing(for text: Text, createMode: Bool = false, showEmojiPicker: Bool, onUpdate: @escaping (Text) -> Void) {
    
    if createMode {
      self.createMode = createMode
    }
    let inputText = text.copyWith(displayEmojiPicker: showEmojiPicker)

    editingText = inputText
    self.startEditingString = inputText.text
    editCancellable =
    source?.startEditingText(for: inputText, options: .init(showEmojiPickerButton: showEmojiPicker))?.sink(receiveValue: { [weak self] textString in
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
  
  func updateEditingText(with color: ModelColor) {
    guard var text = editingText else { return }
    text.color = color
    self.editingText = text
  }

  func cancelEditing() -> (model: Text?, textWasUpdated: Bool) {
    guard let editingText = editingText else { return (nil, false) }
    if createMode {
      createMode = false
    }
    return cancelEditing(for: editingText)
  }
  
  func cancelEditing(for text: Text) -> (model: Text?, textWasUpdated: Bool) {
    defer {
      updatedTextAnnotationClosure = nil
      editingText = nil
      startEditingString = ""
    }
    
    source?.stopEditingText(for: text)
    if let editingText {
      let textToReturn = editingText.copyWith(displayEmojiPicker: false)
      return (textToReturn, textToReturn.text != startEditingString)
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


private extension Text {
  func copyWith(displayEmojiPicker: Bool) -> Self {
    var modifiedText = self
    modifiedText.displayEmojiPicker = displayEmojiPicker
    return modifiedText
  }
}
