import Foundation
import Cocoa

private enum ResizeSideType {
  case fromRightToLeft
  case fromLeftToRight
}

class ResizeTextTransformation: ResizeTransformation {
  func resizedAnnotation(_ annotation: Text, knobType: TextKnobType, delta: CGVector) -> Text {
    switch knobType {
    case .resizeLeft:
      return resizeRightToLeft(delta: delta, text: annotation, type: .fromLeftToRight)
    case .resizeRight:
      return resizeRightToLeft(delta: delta, text: annotation, type: .fromRightToLeft)
    case .bottomScale:
      return bottomScale(delta: delta, text: annotation)
    }
  }
  
  // MARK: - Resize
  private func resizeRightToLeft(delta: CGVector, text: Text, type: ResizeSideType) -> Text {
    var updatedText = text
    
    updatedText.frame = resizeRightToLeft(text.frame, attributedText: text.attributedText, delta: delta, type: type)
    
    return updatedText
  }
  
  private func resizeRightToLeft(_ frame: CGRect,
                                 attributedText: NSAttributedString,
                                 delta: CGVector,
                                 type: ResizeSideType) -> CGRect {
    let minimumTextViewWidth: CGFloat = 50.0
    
    let offset: CGFloat = type == .fromRightToLeft ? delta.dx * -1.0 : delta.dx
    
    let updatedWidth = frame.width - offset
    
    // ignore resize action if the resulting width will be less than minumum width
    if updatedWidth < minimumTextViewWidth {
      return frame
    }
    
    var updatedFrame = frame
    
    if type == .fromLeftToRight {
      updatedFrame.origin.x += offset
    }
    
    let updatedHeight = Self.calculateHeight(for: attributedText, with: updatedWidth)
    
    updatedFrame.size = CGSize(width: updatedWidth, height: updatedHeight)
    
    return updatedFrame
  }
  
  // MARK: - Scale
  private func bottomScale(delta: CGVector, text: Text) -> Text {
    let minimumTextViewHeight: CGFloat = 10.0

    let height = text.frame.size.height + delta.dy
    
    if height < minimumTextViewHeight {
      return text
    }
    
    let scaleUp = delta.dy > 0
        
    var updatedText = text
    updatedText.frame = CGRect(origin: updatedText.frame.origin,
                               size: .init(width: updatedText.frame.size.width,
                                           height: height))
    
    let boundingBox = textBoundingBox(for: text)
    let updatedFont = FontsLayoutHelper.fontFittingText(updatedText.text,
                                                        in: boundingBox.size,
                                                        fontName: text.style.fontName!,
                                                        scaleUp: scaleUp,
                                                        currentFontSize: updatedText.style.fontSize!)
    
    updatedText.style.fontSize = updatedFont
    
    return updatedText
  }
  
  private func textBoundingBox(for text: Text) -> CGRect {
    let frameBounds = CGRect(origin: .zero, size: text.frame.size)
    
    let insets = NSEdgeInsets(top: 0,
                              left: TextLayoutHelper.containerLinePadding,
                              bottom: 0,
                              right: TextLayoutHelper.containerLinePadding)
    
    return frameBounds.insetBy(dx: insets.left + insets.right, dy: insets.bottom + insets.top)
  }
  
  // MARK: - Reduced widt
  
  // if nil is returned it means that nothing was reduced
  class func reduceHeightIfNeeded(for text: Text) -> Text? {
    let textFrame = text.frame
    let newHeight = calculateHeight(for: text.attributedText, with: textFrame.width)
    
    guard newHeight < textFrame.height else { return nil }
    
    var updatedText = text
    updatedText.updateFrameSize(CGSize(width: textFrame.width, height: newHeight))
    return updatedText
  }
  
  // MARK: - Helpers
  
  class func calculateHeight(for text: NSAttributedString, with width: CGFloat) -> CGFloat {
    TextLayoutHelper.getHeightAttr(for: text,
                                   width: width - TextLayoutHelper.containerLinePadding)
  }
  
}
