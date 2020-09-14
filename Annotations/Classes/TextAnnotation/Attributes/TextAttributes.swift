import AppKit

public struct TextAttributes {
  
  // outline attributes
  public static func outline(outlineWidth: CGFloat, outlineColor: NSColor) -> [NSAttributedString.Key: Any] {
    [
      NSAttributedString.Key.strokeColor: outlineColor,
      NSAttributedString.Key.strokeWidth: outlineWidth,
    ]
  }
  
  // shadow attributes with all available shadow settings
  public static func shadow(color: NSColor,
                            offsetX: CGFloat,
                            offsetY: CGFloat,
                            blur: CGFloat) -> [NSAttributedString.Key: Any] {
    let textShadow = NSShadow()
    textShadow.shadowColor = color
    textShadow.shadowOffset = NSMakeSize(offsetX, offsetY)
    textShadow.shadowBlurRadius = blur
    return [
        NSAttributedString.Key.shadow: textShadow,
    ]
  }
  
  // outline attributes plus shadow attributes with all available shadow settings
  public static func outlineWithShadow(outlineWidth: CGFloat,
                                       outlineColor: NSColor,
                                       shadowColor: NSColor,
                                       shadowOffsetX: CGFloat,
                                       shadowOffsetY: CGFloat,
                                       shadowBlur: CGFloat
                                       ) -> [NSAttributedString.Key: Any] {
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowOffset = NSSize(width: shadowOffsetX,
                                 height: shadowOffsetY)
    shadow.shadowBlurRadius = shadowBlur
    
    return [
      .strokeColor: outlineColor,
      .strokeWidth: outlineWidth,
      .shadow: shadow
    ]
  }
  
  // currently used in the app
  public static func defaultOutlineAttributes() -> [NSAttributedString.Key: Any] {
    outline(outlineWidth: -1.5, outlineColor: NSColor.white)
  }
}
