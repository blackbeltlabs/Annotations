import Foundation

struct Border: Selection {
  let id: String
  
  let lineWidth: CGFloat
  let color: CGColor
  
  let path: CGPath
  
  static func textAnnotationBorder(id: String,
                                   rect: CGRect,
                                   lineWidth: CGFloat) -> Border {
    
    let path = CGPath(rect: rect, transform: nil)
    
    return .init(id: id,
                 lineWidth: lineWidth,
                 color: .init(red: 161.0 / 255.0, green: 161.0 / 255.0, blue: 161.0 / 255.0, alpha: 1.0),
                 path: path)
  }
  
}
