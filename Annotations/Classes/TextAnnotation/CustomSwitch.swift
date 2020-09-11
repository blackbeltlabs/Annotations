import Foundation

public class CustomSwitch: NSControl {
  public static let bundle = Bundle(for: CustomSwitch.self)
  
  public var tintColor = NSColor(red: 0.243, green: 0.235, blue: 0.243, alpha: 1.0) {
    didSet {
      reloadLayer()
    }
  }
  public var knobBackgroundColor = NSColor(white: 1.0, alpha: 1.0) {
    didSet {
      reloadLayer()
    }
  }
  public var disabledBorderColor = NSColor(white: 0.0, alpha: 0.2) {
    didSet {
      reloadLayer()
    }
  }
  public var disabledBackgroundColor = NSColor(red: 0.243, green: 0.235, blue: 0.243, alpha: 1.0)  {
    didSet {
      reloadLayer()
    }
  }
  public var inactiveBackgroundColor = NSColor(white: 0.0, alpha: 0.3) {
    didSet {
      reloadLayer()
    }
  }
  public var animationDuration: TimeInterval = 0.4
  public var inactiveIcon = bundle.image(forResource: "T_shadow_selected") {
    didSet {
      reloadLayer()
    }
  }
  public var activeIcon = bundle.image(forResource: "T_shadow_unselected") {
    didSet {
      reloadLayer()
    }
  }
  public var secondIcon = bundle.image(forResource: "T_outline") {
    didSet {
      reloadLayer()
    }
  }
  
  override public var isEnabled: Bool {
    didSet {
      reloadLayerAnimated(animated: true)
    }
  }
  
  lazy var kBorderLineWidth: CGFloat = 0
  let kEnabledOpacity: Float = 1.0
  let kDisabledOpacity: Float = 0.5
  var dragEvents = 0
  
  public var isOn: Bool = false
  public var isActive: Bool = false
  public var hasDragged: Bool  = false
  public var isDraggingTowardsOn: Bool = false
  public var lockInteraction: Bool = false
  public let rootLayer = CALayer()
  public let backgroundLayer = CALayer()
  public let knobLayer = CALayer()
  public let icon1Layer = CALayer()
  public let icon2Layer = CALayer()
  
  override public var acceptsFirstResponder: Bool {
    true
  }
  
  required public init?(coder:NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  convenience public init(size: CGSize) {
    self.init(frame: NSRect(origin: .zero, size: size))
  }
  
  override public init(frame: NSRect) {
    super.init(frame: frame)
    setup()
  }
  
  internal func setup() {
    isEnabled = true
    setupLayers()
    reloadLayerSize()
    setupIcon()
    reloadLayer()
  }
  
  public func setOn(isOn: Bool, animated: Bool) {
    guard self.isOn != isOn else {
      return
    }
    
    self.isOn = isOn
    reloadLayerAnimated(animated: animated)
  }
  
  internal func setupIcon() {
    guard let icon = inactiveIcon else {
      return
    }
    
    let bounds = knobLayer.bounds
    let size = icon.size
    icon1Layer.frame = NSMakeRect((bounds.width-size.width) / 2,
                                  (bounds.height-size.height) / 2,
                                  size.width,
                                  size.height)
    icon1Layer.contents = icon
    
    icon2Layer.frame = NSMakeRect((self.bounds.width - bounds.width / 2 - size.width / 2),
                                  (bounds.height-size.height) / 2,
                                  size.width,
                                  size.height)
    icon2Layer.contents = secondIcon
  }
  
  internal func animateImage(for layer: CALayer, isSelected: Bool) {
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.contents))
    animation.toValue = isSelected ? activeIcon : inactiveIcon
    animation.fromValue = layer.contents
    animation.duration = 0.5
    animation.isRemovedOnCompletion = false
    animation.fillMode = .forwards
    layer.add(animation, forKey: #keyPath(CALayer.contents))
    layer.setValue(animation.toValue, forKey: #keyPath(CALayer.contents))
  }
  
  internal func setupLayers() {
    layer = rootLayer
    wantsLayer = true
    layer?.masksToBounds = false
    
    backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
    backgroundLayer.bounds = rootLayer.bounds
    backgroundLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    backgroundLayer.borderWidth = 0
    backgroundLayer.masksToBounds = false
    rootLayer.addSublayer(backgroundLayer)
    
    knobLayer.frame = rectForKnob()
    knobLayer.autoresizingMask = CAAutoresizingMask.layerHeightSizable
    knobLayer.backgroundColor = knobBackgroundColor.cgColor
    knobLayer.masksToBounds = false
    
    rootLayer.addSublayer(knobLayer)
    rootLayer.addSublayer(icon1Layer)
    rootLayer.addSublayer(icon2Layer)
    
    reloadLayerSize()
    reloadLayer()
  }
  
  internal func reloadLayerSize() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    knobLayer.frame = rectForKnob()
    backgroundLayer.cornerRadius = backgroundLayer.bounds.size.height / 2.0
    knobLayer.cornerRadius = knobLayer.bounds.size.height / 2.0
    CATransaction.commit()
  }
  
  public func reloadLayerAnimated(animated: Bool) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(animated ? animationDuration : 0)
    
    if (hasDragged && isDraggingTowardsOn) || (!hasDragged && isOn) {
      backgroundLayer.borderColor = tintColor.cgColor
      backgroundLayer.backgroundColor = tintColor.cgColor
    } else {
      backgroundLayer.borderColor = disabledBorderColor.cgColor
      backgroundLayer.backgroundColor = disabledBackgroundColor.cgColor
    }
    
    knobLayer.shadowColor = isEnabled ? NSColor.black.cgColor : NSColor.clear.cgColor
    rootLayer.opacity = isEnabled ? kEnabledOpacity : kDisabledOpacity
    
    if hasDragged {
      let function = CAMediaTimingFunction(controlPoints: 0.25, 1.5, 0.5, 1)
      CATransaction.setAnimationTimingFunction(function)
    }
    
    knobLayer.frame = rectForKnob()
    
    CATransaction.commit()
    animateImage(for: icon1Layer, isSelected: isOn)
  }
  
  public func reloadLayer() {
    reloadLayerAnimated(animated: true)
  }
  
  internal func knobHeightForSize(_ size: NSSize) -> CGFloat {
    return size.height - kBorderLineWidth * 2.0
  }
  
  internal func rectForKnob() -> CGRect {
    let height = knobHeightForSize(backgroundLayer.bounds.size)
    let width = 29.0
    
    let bounds: CGRect = backgroundLayer.bounds
    
    var x: CGFloat = 0
    if (!hasDragged && !isOn) || (hasDragged && !isDraggingTowardsOn) {
      x = kBorderLineWidth
    } else {
      x = bounds.width - CGFloat(width) - kBorderLineWidth
    }
    
    return CGRect(x: x + 1, y: 1, width: CGFloat(width) - 2, height: height - 2)
  }
  
  override public func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    
    reloadLayerSize()
  }
  
  override public func acceptsFirstMouse(for theEvent: NSEvent!) -> Bool {
    return true
  }
  
  
  override public func mouseDown(with theEvent: NSEvent) {
    if !isEnabled || lockInteraction {
      return
    }
    isActive = true
    reloadLayer()
  }
  
  override public func mouseDragged(with theEvent: NSEvent) {
    dragEvents += 1
    guard dragEvents > 3 else {
      return
    }
    dragEvents = 0
    if !isEnabled || lockInteraction {
      return
    }
    hasDragged = true
    
    let draggingPoint = convert(theEvent.locationInWindow, from: nil)
    isDraggingTowardsOn = draggingPoint.x > bounds.width  / 2.0
    reloadLayer()
  }
  
  override public func mouseUp(with theEvent: NSEvent) {
    dragEvents = 0
    if !isEnabled || lockInteraction {
      return
    }
    
    var on = isOn
    isActive = false
    if hasDragged {
      on = isDraggingTowardsOn
    } else {
      on = !isOn
    }
    
    if isOn != on {
      isOn = on
      if action != nil {
        NSApp.sendAction(action!, to: target, from: self)
      }
    } else {
      isOn = on
    }
    
    hasDragged = false
    isDraggingTowardsOn = false
    
    reloadLayer()
  }
}
