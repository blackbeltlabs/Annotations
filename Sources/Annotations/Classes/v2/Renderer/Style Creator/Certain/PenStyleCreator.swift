import CoreGraphics

class PenStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Pen) -> LayerUISettings {
    .init(lineWidth: 5,
          strokeColor: figure.color.cgColor,
          fillColor: CGColor.clear)
  }
}
