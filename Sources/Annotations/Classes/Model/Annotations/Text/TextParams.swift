import AppKit

public struct TextParams: Codable, Equatable {
  // MARK: - Properties
  public var fontName: String?
  public var fontSize: Double?
  public var foregroundColor: ModelColor?
  public var outlineWidth: Double?
  public var outlineColor: ModelColor?
  public var shadowColor: ModelColor?
  public var shadowOffsetX: Double?
  public var shadowOffsetY: Double?
  public var shadowBlur: Double?
  
  // MARK: - Init
  public init(fontName: String? = nil,
              fontSize: Double? = nil,
              foregroundColor: ModelColor? = nil,
              outlineWidth: Double? = nil,
              outlineColor: ModelColor? = nil,
              shadowColor: ModelColor? = nil,
              shadowOffsetX: Double? = nil,
              shadowOffsetY: Double? = nil,
              shadowBlur: Double? = nil) {
    self.fontName = fontName
    self.fontSize = fontSize
    self.foregroundColor = foregroundColor
    self.outlineWidth = outlineWidth
    self.outlineColor = outlineColor
    self.shadowColor = shadowColor
    self.shadowOffsetX = shadowOffsetX
    self.shadowOffsetY = shadowOffsetY
    self.shadowBlur = shadowBlur
  }
  
  
  enum CodingKeys: String, CodingKey {
    case fontName = "font_name"
    case fontSize = "font_size"
    case foregroundColor = "foreground_color"
    case outlineWidth = "outline_width"
    case outlineColor = "outline_color"
    case shadowColor = "shadow_color"
    case shadowOffsetX = "shadow_offset_x"
    case shadowOffsetY = "shadow_offset_y"
    case shadowBlur = "shadow_blur"
  }
  
  public static func defaultFont() -> TextParams {
    TextParams(fontName: "HelveticaNeue-Bold",
               fontSize: 30.0)
  }
  
  public static func randomFont() -> TextParams {
    let fonts = NSFontManager.shared.availableFonts
    let randomFont = fonts.randomElement()
    return TextParams(fontName: randomFont,
                      fontSize: Double.random(in: 20..<40.0),
                      foregroundColor: ModelColor.random(),
                      outlineWidth: Double.random(in: -4.0..<0),
                      outlineColor: ModelColor.random(),
                      shadowColor: ModelColor.random(),
                      shadowOffsetX: Double.random(in: -3.0..<3.0),
                      shadowOffsetY: Double.random(in: -3.0..<3.0),
                      shadowBlur: Double.random(in: 0..<6.0))
  }
  
  public static func empty() -> TextParams {
    TextParams()
  }
  
  // get attributes from current params
  var attributes: [NSAttributedString.Key: Any] {
    
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    
    if let fontName = self.fontName {
      let size: CGFloat
      
      if let fontSize = self.fontSize {
        size = CGFloat(fontSize)
      } else {
        size = 30.0
      }
      
      let font = FontsLayoutHelper.fontOrDefault(for: fontName, fontSize: size)
      attributes[.font] = font
    } else if let fontSize = self.fontSize {
      attributes[.font] = NSFont.systemFont(ofSize: CGFloat(fontSize))
    } else {
      attributes[.font] = NSFont.systemFont(ofSize: 30.0)
    }
    
    if let foregroundColor = self.foregroundColor {
      attributes[.foregroundColor] = NSColor.color(from: foregroundColor)
    }
    
    
    if let outlineWidth = self.outlineWidth {
      attributes[.strokeWidth] = CGFloat(outlineWidth)
    }
    
    if let outlineColor = self.outlineColor {
      attributes[.strokeColor] = NSColor.color(from: outlineColor)
    }
    
    
    if shadowColor != nil || shadowOffsetX != nil || shadowOffsetY != nil || shadowBlur != nil {
      let shadow = NSShadow()
      
      if let shadowColor = self.shadowColor {
        shadow.shadowColor = NSColor.color(from: shadowColor)
      }
      
      if let shadowOffsetX = self.shadowOffsetX,
         let shadowOffsetY = self.shadowOffsetY {
        shadow.shadowOffset = NSSize(width: shadowOffsetX, height: shadowOffsetY)
      }
      
      if let shadowBlur = self.shadowBlur {
        shadow.shadowBlurRadius = CGFloat(shadowBlur)
      }
      
      attributes[.shadow] = shadow
    }
    
    return attributes
  }
  
  public static func textParams(from attributes: [NSAttributedString.Key: Any]) -> TextParams {
    var params = TextParams()
    if let font = attributes[.font] as? NSFont {
      params.fontName = font.fontName
      params.fontSize = Double(font.pointSize)
    }
    
    if let foregroundColor = attributes[.foregroundColor] as? NSColor {
      params.foregroundColor = foregroundColor.annotationModelColor
    }
    
    if let outlineWidth = attributes[.strokeWidth] as? CGFloat {
      params.outlineWidth = Double(outlineWidth)
    }
    
    if let outlineColor = attributes[.strokeColor] as? NSColor {
      params.outlineColor = outlineColor.annotationModelColor
    }
    
    if let shadow = attributes[.shadow] as? NSShadow {
      if let color = shadow.shadowColor {
        params.shadowColor = color.annotationModelColor
      }
      params.shadowOffsetX = Double(shadow.shadowOffset.width)
      params.shadowOffsetY = Double(shadow.shadowOffset.height)
      
      params.shadowBlur = Double(shadow.shadowBlurRadius)
    }
    
    return params
  }
  
  // update with another model with the following rule:
  // each text param will be updated if it is current value is nil
  public func updatedModelWithTextParamsIfNil(_ textParams: TextParams) -> TextParams {
    
    var newModel = self
    
    if fontName == nil {
      newModel.fontName = textParams.fontName
    }
    
    if fontSize == nil {
      newModel.fontSize = textParams.fontSize
    }
    
    if foregroundColor == nil {
      newModel.foregroundColor = textParams.foregroundColor
    }
    
    if outlineWidth == nil {
      newModel.outlineWidth = textParams.outlineWidth
    }
    
    if outlineColor == nil {
      newModel.outlineColor = textParams.outlineColor
    }
    
    if shadowColor == nil {
      newModel.shadowColor = textParams.shadowColor
    }
    
    if shadowOffsetX == nil {
      newModel.shadowOffsetX = textParams.shadowOffsetX
    }
    
    if shadowOffsetY == nil {
      newModel.shadowOffsetY = textParams.shadowOffsetY
    }
    
    if shadowBlur == nil {
      newModel.shadowBlur = textParams.shadowBlur
    }
    
    return newModel
  }
  
  public func updatedWithColor(_ modelColor: ModelColor) -> TextParams {
    var newModel = self
    newModel.foregroundColor = modelColor
    return newModel
  }
}
