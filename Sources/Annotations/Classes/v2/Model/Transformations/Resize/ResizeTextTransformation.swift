import Foundation

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
      return annotation
    }
  }
  
  private func resizeRightToLeft(delta: CGVector, text: Text, type: ResizeSideType) -> Text {
    var updatedText = text
    
    updatedText.frame = resizeRightToLeft(text.frame, attributedText: text.attributedText, delta: delta, type: type)
    
    return updatedText
  }
  
  private func resizeRightToLeft(_ frame: CGRect, attributedText: NSAttributedString, delta: CGVector, type: ResizeSideType) -> CGRect {
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
    
    let updatedHeight = TextLayoutHelper.getHeightAttr(for: attributedText,
                                                       width: updatedWidth - TextLayoutHelper.containerLinePadding)
    
    updatedFrame.size = CGSize(width: updatedWidth, height: updatedHeight)
    
    return updatedFrame
  }
}
