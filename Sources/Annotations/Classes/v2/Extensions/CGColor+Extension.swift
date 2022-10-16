import CoreGraphics

extension CGColor {
  static var commonKnobBorderColor: CGColor {
    .white
  }
  
  static var obfuscate: CGColor {
    .init(red: 65.0 / 255.0, green: 70.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
  }
  
  static var zapierOrange: CGColor {
    .init(red: 255.0 / 255.0, green: 76.0 / 255.0, blue: 0, alpha: 1.0)
  }
  
  static var textSideKnobBorderColor: CGColor {
    .init(red: 177.0 / 255.0, green: 177.0 / 255.0, blue: 177.0 / 255.0, alpha: 1.0)
  }
  
  static var textScaleKnobBorderColor: CGColor {
    .white
  }
}
