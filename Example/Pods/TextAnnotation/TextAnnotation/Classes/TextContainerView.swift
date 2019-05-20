//
//  BBContainerView.swift
//  TextAnnotation
//
//  Created by Sergey Vinogradov on 12.04.2019.
//

import Cocoa

public enum TextAnnotationState {
  case inactive
  case active
  case editing
  case resizeRight
  case resizeLeft
  case dragging
  case scaling
}

public protocol ActivateResponder: class {
    func textViewDidActivate(_ activeItem: Any?)
}

open class TextContainerView: NSView {
    // MARK: - Variables
  
  public var state: TextAnnotationState = .inactive {
        didSet {          
            guard state != oldValue else { return }
            
            var isActive: Bool = false
            if state == .inactive {
                textView.isEditable = false
                textView.isSelectable = false
                doubleClickGestureRecognizer.isEnabled = !textView.isEditable
            } else {
                if state == .scaling {
                    textView.calculateScaleRatio()
                }
                
                isActive = true
                
                if let responder = activateResponder {
                    responder.textViewDidActivate(self)
                }
            }
            
            singleClickGestureRecognizer.isEnabled = state == .inactive
            
            backgroundView.isHidden = !isActive
            backgroundView.display()
            
            if let tally = leftTally {
                tally.isHidden = !isActive
            }
            
            if let tally = rightTally {
                tally.isHidden = !isActive
            }
            
            if let tally = scaleTally {
                tally.isHidden = !isActive
                tally.display()
            }
        }
    }
    
    weak var activateResponder: ActivateResponder?
    weak var activeAreaResponder: MouseTrackingResponder?
    
    public var text: String = "" {
        didSet {
            guard textView != nil else { return }
            textView.string = text
            updateFrameWithText(textView.string)
        }
    }
    var leftTally: MouseTrackingView?
    var rightTally: MouseTrackingView?
    var scaleTally: KnobView?
    
    // MARK: Private
    
    private var backgroundView: SelectionView!
    private var textView: TextView!
    
    private let kMinimalWidth: CGFloat = 25 + 2*Configuration.frameMargin + 2*Configuration.dotRadius
    private let kMinimalHeight: CGFloat = 25
    
    private var singleClickGestureRecognizer: NSClickGestureRecognizer!
    private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
  
    private var lastMouseLocation: NSPoint?
  
    private var cursorSet = CursorSet.shared
  
    override open var frame: NSRect {
        didSet {
            updateSubviewsFrames(oldValue, frame: frame)
        }
    }
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let size = frameRect.size
        
        backgroundView = SelectionView(frame: NSRect(origin: CGPoint.zero, size: size))
        backgroundView.isHidden = true
        self.addSubview(backgroundView)
        
        textView = TextView(frame: NSRect.zero, responder: self)
        textView.alignment = .natural
        textView.backgroundColor = NSColor.clear
        textView.textColor = Palette.controlFillColor
        textView.font = NSFont(name: "HelveticaNeue-Bold", size: 30)
        textView.isSelectable = false
        textView.isRichText = false
        textView.usesRuler = false
        textView.usesFontPanel = false
        textView.isEditable = false
        textView.isVerticallyResizable = false
        textView.delegate = self
        
        singleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.singleClickGestureHandle(_:)))
        self.addGestureRecognizer(singleClickGestureRecognizer)
      
        doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.doubleClickGestureHandle(_:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        doubleClickGestureRecognizer.numberOfTouchesRequired = 2
        self.addGestureRecognizer(doubleClickGestureRecognizer)
      
        addSubview(textView)
        
        // all frames here is zero, later we set it in updateSubviewsFrames()
        let tallyFrame = NSRect.zero
        var flipper = MouseTrackingView(type: .resizeLeftArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        leftTally = flipper
        
        flipper = MouseTrackingView(type: .resizeRightArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        rightTally = flipper
        
        let tally = KnobView(type: .scaleArea, responder: self, frameRect: tallyFrame)
        tally.isHidden = true
        addSubview(tally)
        scaleTally = tally
    }
    
    required public init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
  
  open override func mouseDown(with event: NSEvent) {
    let mouseLocation = self.convert(event.locationInWindow, from: nil)
    state = mouseDownState(location: mouseLocation)

    lastMouseLocation = mouseLocation
  }
  
  open override func mouseDragged(with event: NSEvent) {
    guard let lastMouseLocation = lastMouseLocation else {
      return
    }
    
    let mouseLocation = self.convert(event.locationInWindow, from: nil)
    self.lastMouseLocation = mouseLocation
    
    let difference = CGSize(
      width: mouseLocation.x - lastMouseLocation.x,
      height: mouseLocation.y - lastMouseLocation.y
    )
    
    switch state {
    case .active:
      move(difference: difference)
    case .resizeLeft, .resizeRight:
      resize(distance: difference.width)
    case .scaling:
      scale(difference: difference)
      cursorSet.scaleCursor.set()
    default: return
    }
  }
  
  open override func mouseUp(with event: NSEvent) {
    state = .active

    lastMouseLocation = nil
  }
    
    @objc private func singleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        state = .active
    }
    
    @objc private func doubleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        
        state = .editing
        textView.isSelectable = true
        theTextView.isEditable = true
        doubleClickGestureRecognizer.isEnabled = !theTextView.isEditable
        
        guard let responder = activateResponder else { return }
        responder.textViewDidActivate(self)
    }
    
    private func updateFrameWithText(_ string: String) {
        let center = CGPoint(x: NSMidX(frame), y: NSMidY(frame))
        
        var textFrame = textView.frameForWidth(CGFloat.greatestFiniteMagnitude, height: textView.bounds.height)
        let width = max(textFrame.width + textView.twoSymbolsWidth, textView.bounds.width)
        
        // We should use minimal value to get height. Because of multiline.
        let minWidth = min(textFrame.width + textView.twoSymbolsWidth, textView.bounds.width)
        textFrame = textView.frameForWidth(minWidth, height: CGFloat.greatestFiniteMagnitude)
        let height = textFrame.height
        
        // Now we know text label frame. We should calculate new self.frame and redraw all the subviews
        textFrame = CGRect(x: frame.minX,
                           y: center.y - height/2.0 - (Configuration.frameMargin + Configuration.horizontalTextPadding),
                           width: width + 2*(Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding),
                           height: height + 2*(Configuration.frameMargin + Configuration.horizontalTextPadding))
        
        frame = textFrame
    }
    
    private func updateSubviewsFrames(_ oldFrame: NSRect, frame: NSRect) {
        if oldFrame.width == frame.width && oldFrame.height == frame.height {
            return
        }
      
        let size = frame.size
        
        backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
        textView.frame = CGRect(x: Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding, y: Configuration.frameMargin + Configuration.horizontalTextPadding, width: size.width - 2*(Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding), height: size.height - 2 * (Configuration.frameMargin + Configuration.horizontalTextPadding))
        
        var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: Configuration.frameMargin + 2*Configuration.dotRadius, height: size.height))
        if let tally = leftTally {
            tally.frame = tallyFrame
        }
        
        if let tally = rightTally {
            tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
            tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - (2*Configuration.dotRadius + Configuration.frameMargin))
            tally.frame = tallyFrame
        }
        
        if let tally = scaleTally {
            tallyFrame.origin = CGPoint(x: size.width - (Configuration.frameMargin + 2*Configuration.dotRadius), y: Configuration.frameMargin)
            tallyFrame.size = CGSize(width: 2*Configuration.dotRadius, height: 2*Configuration.dotRadius)
            tally.frame = tallyFrame
        }
    }
    
    // MARK: - Public
  
    func move(difference: CGSize) {
        var newFrame = frame
        newFrame.origin = CGPoint(
            x: frame.origin.x + difference.width,
            y: frame.origin.y + difference.height
        )
      
        frame = newFrame
    }
  
    public func resize(distance: CGFloat) {
        guard state == .resizeRight || state == .resizeLeft else { return }
        
        var theFrame = frame
        let delta = (state == .resizeRight ? 1 : -1) * distance
        var width = theFrame.width + delta
        width = width < kMinimalWidth ? kMinimalWidth : width
        theFrame.size = CGSize(width: width, height: theFrame.height)
        
        if state == .resizeLeft {
            // should move origin as well
            theFrame.origin = CGPoint(x: theFrame.origin.x + distance, y: theFrame.origin.y)
        }
        
        // Here we have to check if text view frame has good size for such container size
        let textFrame = textView.frameForWidth(theFrame.width - 2 * (Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding),
                                               height: CGFloat.greatestFiniteMagnitude)
        let diff_width = theFrame.width - (textFrame.width + 2 * (Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding) + textView.twoSymbolsWidth)
        if diff_width < 0 {
            let height = textFrame.height + 2 * (Configuration.frameMargin + Configuration.horizontalTextPadding)
            let centerY = theFrame.origin.y + theFrame.height/2
            
            theFrame.size = CGSize(width: theFrame.width, height: height)
            theFrame.origin = CGPoint(x: theFrame.origin.x, y: centerY - height/2)
        }
        
        frame = theFrame
    }
    
    public func scale(difference: CGSize) {
        guard state == .scaling else { return }
        
        // we should scale it proportionally, driver of the mpvement is height difference
        var height = frame.height - difference.height
        var width = frame.width/frame.height * height
        
        width = width < kMinimalWidth ? kMinimalWidth : width
        height = height < kMinimalHeight ? kMinimalHeight : height
      
        frame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y + difference.height),
                       size: CGSize(width: width, height: height))
        textView.resetFontSize()
    }
  
    public func mouseDownState(location: NSPoint) -> TextAnnotationState {
        var state = TextAnnotationState.active // default state
        if let tally = leftTally, tally.frame.contains(location) {
            state = .resizeLeft
        } else if let tally = rightTally, tally.frame.contains(location) {
            state = .resizeRight
        } else if let tally = scaleTally, tally.frame.contains(location) {
            state = .scaling
        }
        
        return state
    }
}

extension TextContainerView: NSTextViewDelegate {
    
    // MARK: - NSTextDelegate
    
    open func textDidChange(_ notification: Notification) {
        updateFrameWithText(textView.string)
    }
}

extension TextContainerView: ActivateResponder {
  public func textViewDidActivate(_ activeItem: Any?) {
        // After we reach the .editing state - we should not switch it back to .active, only on .inactive on complete edit
        state = textView.isEditable ? .editing : .active
    }
}

extension TextContainerView: MouseTrackingResponder {
  public func areaDidActivated(_ area: TextAnnotationArea) {
        guard let areaResponder = activeAreaResponder, state == .active else { return }
        areaResponder.areaDidActivated(area)
    }
}
