import CoreGraphics

class PenStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Pen) -> LayerUISettings {
    .init(lineWidth: figure.lineWidth,
          strokeColor: figure.color.cgColor,
          fillColor: CGColor.clear)
  }
}
