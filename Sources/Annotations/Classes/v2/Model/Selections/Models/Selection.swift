import Foundation

protocol Selection {
  var id: String { get }
}

struct Border: Selection {
  let id: String
  
  let lineWidth: CGFloat
  let color: CGColor
  
  let path: CGPath
  
  
  static func textAnnotationBorder(id: String = UUID().uuidString,
                                   from textRect: CGRect) -> Border {
    
    let path = CGPath(rect: textRect, transform: nil)
    
    return .init(id: id,
                 lineWidth: 4.0,
                 color: .init(red: 161.0 / 255.0, green: 161.0 / 255.0, blue:  161.0 / 255.0, alpha: 1.0),
                 path: path)
  }
  
}
