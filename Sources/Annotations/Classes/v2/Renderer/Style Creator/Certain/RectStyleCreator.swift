import Cocoa

class RectStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Rect) -> LayerUISettings {
    switch figure.rectType {
    case .regular:
      return .init(lineWidth: 5,
                   strokeColor: figure.color.cgColor,
                   fillColor: CGColor.clear)
    case .obfuscate:
      return .init(lineWidth: 2,
                   strokeColor: NSColor.red.cgColor,
                   fillColor: .black)
    case .highlight:        
      return .init(lineWidth: 0,
                   strokeColor: NSColor.black.cgColor,
                   fillColor: NSColor.red.cgColor)
    }
  }
}


class NumberStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Number) -> LayerUISettings {
    .init(lineWidth: 0, strokeColor: .clear, fillColor: figure.color.cgColor)
  }
}
