import QuartzCore

extension CanvasShapeLayer {
  func addLineDashPhaseAnimation(_ animation: LineDashPhaseAnimation) {
    lineDashPattern = animation.lineDashPattern
    
    let lineDashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
    lineDashAnimation.fromValue = animation.fromValue
    lineDashAnimation.toValue = animation.toValue
    lineDashAnimation.duration = animation.duration
    lineDashAnimation.repeatCount = animation.repeatCount
    add(lineDashAnimation, forKey: animation.animationKey)
  }
  
  func removeLineDashPhaseAnimation(key: String) {
    lineDashPattern = nil
    removeAnimation(forKey: "temp")
  }
}
