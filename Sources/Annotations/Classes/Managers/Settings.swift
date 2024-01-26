import AppKit
import Combine

public enum ObfuscateType: Equatable {
  case solid
  case imagePattern(_ image: NSImage)
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    (lhs.isSolid && rhs.isSolid) || (lhs.isImagePattern && rhs.isImagePattern)
  }
  
  var isSolid: Bool {
    switch self {
    case .solid:
      return true
    default:
      return false
    }
  }
  
  var isImagePattern: Bool {
    switch self {
    case .imagePattern:
      return true
    default:
      return false
    }
  }
}

public final class Settings {
  // MARK: - Input (from app that uses Annotations)
  public let isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  public let obfuscateType = CurrentValueSubject<ObfuscateType, Never>(.solid)
  public let currentAnnotationTypeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  public let createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
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
  
  public func setIsUserInteractionEnabled(_ enabled: Bool) {
    isUserInteractionEnabled.send(enabled)
  }
  
  public func setObfuscateType(_ type: ObfuscateType) {
    obfuscateType.send(type)
  }
  
  public func setCurrentAnnotationType(_ itemType: CanvasItemType?) {
    currentAnnotationTypeSubject.send(itemType)
  }
  
  public func setColor(_ color: ModelColor) {
    createColorSubject.send(color)
  }

  public func setTextStyle(_ style: TextParams) {
    textStyleSubject.send(style)
  }
}
