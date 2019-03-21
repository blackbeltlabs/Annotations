//
//  TextView.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/7/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa

protocol TextViewDelegate {
  func textView(_ textView: TextView, didUpdate model: TextModel, atIndex index: Int)
  func textView(_ textView: TextView, didEndEditing model: TextModel)
}

struct TextViewState {
  var model: TextModel
  var isSelected: Bool
}

protocol TextView: CanvasDrawable, MultilineTextViewDelegate {
  var state: TextViewState { get set }
  var delegate: TextViewDelegate? { get set }
  var textView: MultilineTextView { get }
}

extension TextView {
  
  func render(state: TextViewState, oldState: TextViewState? = nil) {
    textView.string = state.model.text
    
    if state.model.origin != oldState?.model.origin {
      
    }
    
    if state.isSelected != oldState?.isSelected {
      if state.isSelected {
        
      } else {
        let _ = textView.resignFirstResponder()
      }
    }
  }
  
  func multilineTextViewDidStartEditing(_ sender: MultilineTextView) {
    
  }
  
  func multilineTextViewSelected(_ sender: MultilineTextView) {
    
  }
  
  func multilineTextViewDidChange(_ sender: MultilineTextView) {
    state.model.text = sender.string
    delegate?.textView(self, didUpdate: state.model, atIndex: modelIndex)
  }
  
  func multilineTextViewDidEndEditing(_ sender: MultilineTextView) {
    delegate?.textView(self, didEndEditing: state.model)
  }
}

class TextViewClass: TextView {
  var delegate: TextViewDelegate?
  
  var state: TextViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var textView: MultilineTextView
  
  var modelIndex: Int
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = isSelected }
  }
  
  init(state: TextViewState, modelIndex: Int) {
    self.state = state
    self.modelIndex = modelIndex
    
    textView = MultilineTextView()
    textView.multilineTextViewDelegate = self
    
    render(state: state)
  }
  
  func addTo(canvas: CanvasView) {
    let view = canvas.view
    let origin = state.model.origin
    
    view.addConstrained(subviews: textView)
    textView.xConstraint = textView.centerX.snap(anchor: view.left, offset: CGFloat(origin.x))
    textView.yConstraint = textView.centerY.snap(anchor: view.bottom, offset: CGFloat(-origin.y))
    textView.left.snapGreater(anchor: view.left)
    textView.right.snapLess(anchor: view.right)
  }
  
  func removeFrom(canvas: CanvasView) {
    textView.removeFromSuperview()
  }
  
  func contains(point: PointModel) -> Bool {
    return textView.frame.contains(point.cgPoint)
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return nil
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    
  }
  
  func dragged(from: PointModel, to: PointModel) {
    
  }
}

protocol MultilineTextViewDelegate {
  func multilineTextViewDidStartEditing(_ sender: MultilineTextView)
  func multilineTextViewDidChange(_ sender: MultilineTextView)
  func multilineTextViewDidEndEditing(_ sender: MultilineTextView)
  func multilineTextViewSelected(_ sender: MultilineTextView)
}

class MultilineTextView: NSTextView {
  var multilineTextViewDelegate: MultilineTextViewDelegate?
  
  var xConstraint: NSLayoutConstraint?
  var yConstraint: NSLayoutConstraint?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    alignment = .center
    delegate = self
    drawsBackground = false
    textColor = NSColor.red
    font = NSFont.boldSystemFont(ofSize: 30)
    textContainer?.widthTracksTextView = true
    wantsLayer = true
    
    let knob = KnobViewClass(model: PointModel(x: 0, y: 0))
    layer?.masksToBounds = false
    layer?.addSublayer(knob.layer)
  }
  
  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize: NSSize {
    let maxWidthRight = superview!.frame.width - frame.minX - 10
    let maxWidthLeft = frame.minX * 2
    let maxWidth = min(maxWidthRight, maxWidthLeft)
    let maxSize = CGSize(width: maxWidth, height: 0)
    let measuredString = string == "" ? " " : string
    var size = measuredString.sizeWithFont(font!, maxSize: maxSize)
    size.width = size.width + 10
    
    return size
  }
  
  override func mouseDown(with event: NSEvent) {
    multilineTextViewDelegate?.multilineTextViewSelected(self)
    
    super.mouseDown(with: event)
  }
  
  override func becomeFirstResponder() -> Bool {
    multilineTextViewDelegate?.multilineTextViewDidStartEditing(self)
    
    return true
  }
  
  override func resignFirstResponder() -> Bool {
    
    return super.resignFirstResponder()
  }
}

extension MultilineTextView: NSTextViewDelegate {
  func textDidEndEditing(_ notification: Notification) {
    multilineTextViewDelegate?.multilineTextViewDidEndEditing(self)
  }
  
  func textDidChange(_ notification: Notification) {
    multilineTextViewDelegate?.multilineTextViewDidChange(self)
    invalidateIntrinsicContentSize()
  }
}
