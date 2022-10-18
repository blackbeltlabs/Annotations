import Cocoa
import Combine

public final class Settings {
  // MARK: - Input (from app that uses Annotations)
  public let solidColorForObsfuscate = CurrentValueSubject<Bool, Never>(false)
  public let isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  public let currentAnnotationTypeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  public let createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
  public let backgroundImageSubject = PassthroughSubject<NSImage, Never>()
  public let textStyleSubject = CurrentValueSubject<TextParams, Never>(.defaultFont())
  
  // MARK: - Output (from Annotations to external)
  let textViewIsEditingSubject = PassthroughSubject<Bool, Never>()
  let emojiPickerIsPresented = PassthroughSubject<Bool, Never>()
  
  public var textViewIsEditingPublisher: AnyPublisher<Bool, Never> {
    textViewIsEditingSubject.eraseToAnyPublisher()
  }
  
  public var emojiPickerIsPresentedPublisher: AnyPublisher<Bool, Never> {
    emojiPickerIsPresented.eraseToAnyPublisher()
  }
  
  // Convenient non-Combine functions
  public func setSolidColorForObfuscute(_ enabled: Bool) {
    solidColorForObsfuscate.send(enabled)
  }
  
  public func setIsUserInteractionEnabled(_ enabled: Bool) {
    isUserInteractionEnabled.send(enabled)
  }
  
  public func setCurrentAnnotationType(_ itemType: CanvasItemType?) {
    currentAnnotationTypeSubject.send(itemType)
  }
  
  public func setColor(_ color: ModelColor) {
    createColorSubject.send(color)
  }
  
  public func setBackgroundImage(_ image: NSImage){
    backgroundImageSubject.send(image)
  }
  
  public func setTextStyle(_ style: TextParams) {
    textStyleSubject.send(style)
  }
}
