import Cocoa
import Combine

public final class Settings {
  public let solidColorForObsfuscate = CurrentValueSubject<Bool, Never>(false)
  public let isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  public let currentAnnotationTypeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  public let createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
  public let backgroundImageSubject = PassthroughSubject<NSImage, Never>()
  public let textStyleSubject = CurrentValueSubject<TextParams, Never>(.defaultFont())
  
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
