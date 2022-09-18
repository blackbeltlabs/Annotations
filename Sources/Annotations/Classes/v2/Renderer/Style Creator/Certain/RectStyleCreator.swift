import Cocoa

class RectStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Rect) -> LayerUISettings {
    switch figure.type {
    case .regular:
       return .init(lineWidth: 5,
                    strokeColor: figure.colour.cgColor,
                    fillColor: CGColor.clear)
    case .obfuscate:
        return .init(lineWidth: 2,
                     strokeColor: NSColor.red.cgColor,
                     fillColor: .black)
    case .highlight:
        return .init(lineWidth: 1,
                     strokeColor: nil,
                     fillColor: .clear)
    case .number:
      return .init(lineWidth: 0,
                   strokeColor: .clear,
                   fillColor: figure.colour.cgColor)
    }
  }
}