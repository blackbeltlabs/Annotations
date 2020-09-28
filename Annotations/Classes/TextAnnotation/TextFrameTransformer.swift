import AppKit

class TextFrameTransformer {
  // MARK: - Dependencies
  weak var textContainerView: TextContainerView?
    
  private var textView: NSTextView? {
    textContainerView?.textView
  }
  
  // MARK: - Helpers
  private let stringSizeHelper = StringSizeHelper()
  private let fontSizeHelper = FontSizeHelper()
  
  // MARK: - Properties
  
  // must use this in width calculation otherwise the width will be incorrect
  var containerLinePadding: CGFloat {
    guard let textContainer = textView?.textContainer else { return 0 }
    return textContainer.lineFragmentPadding * 2.0
  }
  
  // MARK: - Transform
  func resize(distance: CGFloat, type: ResizeType) {
    guard let textContainerView = textContainerView,
          let textView = self.textView else { return }
    
    let minimumTextViewWidth: CGFloat = 50.0
    
    let offset: CGFloat = type == .rightToLeft ? distance * -1.0 : distance
    
    let width = textView.frame.size.width - offset
    
    // ignore resize action if the resulting width will be less than minumum width
    if width < minimumTextViewWidth {
      return
    }

    if type == .leftToRight {
      textContainerView.frame.origin.x += offset
    }
    
    let height = stringSizeHelper.getHeightAttr(for: textView.attributedString(),
                                                width: width - containerLinePadding)
    updateTextViewSize(size: CGSize(width: width,
                                    height: height))
  }
  
  func scale(distance: CGFloat) {
    guard let textView = self.textView else { return }
    
    let minimumTextViewHeight: CGFloat = 10.0

    let height = textView.frame.size.height - distance
    
    if height < minimumTextViewHeight {
      return
    }
    
    let width = textView.frame.size.width
    
    updateTextViewSize(size: CGSize(width: width,
                                    height: height))
    
    let font = fontSizeHelper.fontFittingText(textView.string,
                                              in: textView.textBoundingBox.size,
                                              fontDescriptor: textView.font!.fontDescriptor)
    textView.font = font
  }
  
  
  func move(difference: CGSize) {
    guard let textContainerView = self.textContainerView else { return }
    
    textContainerView.frame.origin.x += difference.width
    
    // need minus here because the current view is flipped whereas the position from window is Mac OS native
    textContainerView.frame.origin.y -= difference.height
  }
  
  func updateSize(for text: String) {
    guard let textView = textView else { return }
    let size = stringSizeHelper.bestSizeWithAttributes(for: text,
                                                       attributes: textView.typingAttributes)
    updateTextViewSize(size: size)
  }
  
  // MARK: - Frame updates
  func reduceWidthIfNeeded() {
    guard let textView = textView else { return }
    
    var newWidth = stringSizeHelper.getWidthAttr(for: textView.attributedString(),
                                                 height: textView.frame.size.height)
    
    newWidth += containerLinePadding
    
    // text view width need to be reduced only if a new width is less than the current one
    if newWidth < textView.frame.size.width {
      updateTextViewSize(size: CGSize(width: newWidth,
                                      height: textView.frame.size.height))
    }
  }
  
  func reduceHeightIfNeeded() {
    guard let textView = textView else { return }

    let newHeight = stringSizeHelper.getHeightAttr(for: textView.attributedString(),
                                                   width: textView.frame.size.width)
    
    if newHeight < textView.frame.size.height {
      updateTextViewSize(size: CGSize(width: textView.frame.size.width + containerLinePadding,
                                      height: newHeight))
    }
  }
  
  // MARK: - Private
  // all updates of text view size should be done through this method

  private func updateTextViewSize(size: CGSize) {
    guard let textContainerView = self.textContainerView else { return }
    
    let inset = textContainerView.inset

    textContainerView.frame.size.width = size.width + inset.dx * 2
    textContainerView.frame.size.height = size.height + inset.dy * 2
  }
}
