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
  
  var bounds: CGRect { get }
}

class TextAnnotationsManager {
  var textStyle: TextParams = .defaultFont()
  
  weak var source: TextAnnotationsSource?
  
  private var editCancellable: AnyCancellable?
  
  private var initialTextModel: Text?
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
    
    (editingText, initialTextModel) = (inputText, inputText)
    
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
      (editingText, initialTextModel) = (nil, nil)
    }
    
    source?.stopEditingText(for: text)
    if let editingText {
      let textToReturn = editingText.copyWith(displayEmojiPicker: false)
      return (textToReturn, updatePerformed(for: initialTextModel,
                                            finalText: textToReturn))
    } else {
      return (nil, false)
    }
  }
  
  private func updatePerformed(for initialText: Text?,
                               finalText: Text?) -> Bool {
    guard let initialText, let finalText else { return false }
    
    let result =
    initialText.text != finalText.text ||
    initialText.style != finalText.style ||
    initialText.frame != finalText.frame ||
    initialText.legibilityEffectEnabled != finalText.legibilityEffectEnabled
    
    return result
  }
  
  var isEditing: Bool {
    editingText != nil
  }
  
  
  func handleTextChanged(for text: Text, updatedString: String) {
    guard let source = source else {
      fatalError("Text annotations source is absent")
    }
    
    var updatedText = text
    
    // calculate best size for updated string
    let bestSize = TextLayoutHelper.bestSizeWithAttributes(for: updatedString,
                                                           attributes: text.style.attributes)
    
    updatedText.text = updatedString

    let minBorderDistance = 10.0
    
    // if with updated size a text annotation will be too close to the right border
    // it needs to be resized and part of a text should be move to the next line
    if text.frame.origin.x + bestSize.width > source.bounds.maxX - minBorderDistance {
      let currentWidth = text.frame.size.width // an existing width
      // calculate a new height for existing width
      let height = TextLayoutHelper.calculateHeight(for: updatedText.attributedText,
                                                    withWidth: currentWidth)
      
      updatedText.updateFrameHeight(height)
    } else {
      // just use the best size
      updatedText.updateFrameSize(bestSize)
    }
    
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
