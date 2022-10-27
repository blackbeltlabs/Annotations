import QuartzCore

extension CATransaction {
  static func withoutAnimation(_ closure: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    closure()
    CATransaction.commit()
  }
}
