
import Cocoa

extension NSView {
  
  func moveTo(x: CGFloat? = nil, y: CGFloat? = nil) {
    var moved = frame
    if let x = x {
      moved.origin.x = x
    }
    if let y = y {
      moved.origin.y = y
    }
    frame = moved
  }
  
  func addConstrained(subviews: NSView...) {
    for view in subviews {
      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)
    }
  }
  
  func snap(view: NSView) {
    left.snap(anchor: view.left)
    right.snap(anchor: view.right)
    top.snap(anchor: view.top)
    bottom.snap(anchor: view.bottom)
  }
  
  var centerX: NSLayoutXAxisAnchor {
    return centerXAnchor
  }
  
  var centerY: NSLayoutYAxisAnchor {
    return centerYAnchor
  }
  
  var top: NSLayoutYAxisAnchor {
    return topAnchor
  }
  
  var bottom: NSLayoutYAxisAnchor {
    return bottomAnchor
  }
  
  var left: NSLayoutXAxisAnchor {
    return leftAnchor
  }
  
  var right: NSLayoutXAxisAnchor {
    return rightAnchor
  }
  
  var width: NSLayoutDimension {
    return widthAnchor
  }
  
  var height: NSLayoutDimension {
    return heightAnchor
  }
  
}

extension NSLayoutAnchor {
  
  @objc @discardableResult func snap(anchor: NSLayoutAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = self.constraint(equalTo: anchor, constant: offset)
    constraint.isActive = true
    
    return constraint
  }
  
  @objc @discardableResult func snapGreater(anchor: NSLayoutAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: offset)
    constraint.isActive = true
    
    return constraint
  }
  
  @objc @discardableResult func snapLess(anchor: NSLayoutAnchor, offset: CGFloat = 0) -> NSLayoutConstraint {
    let constraint = self.constraint(lessThanOrEqualTo: anchor, constant: offset)
    constraint.isActive = true
    
    return constraint
  }
  
}

extension NSLayoutDimension {
  
  @discardableResult func snap(value: CGFloat) -> NSLayoutConstraint {
    let constraint = self.constraint(equalToConstant: value)
    constraint.isActive = true
    
    return constraint
  }
  
  func snap(dimension: NSLayoutDimension, multiplier: CGFloat = 1) {
    constraint(equalTo: dimension, multiplier: multiplier).isActive = true
  }
  
  func snapGreater(value: CGFloat) {
    constraint(greaterThanOrEqualToConstant: value).isActive = true
  }
  
  func snapLess(value: CGFloat) {
    constraint(lessThanOrEqualToConstant: value).isActive = true
  }
  
}
