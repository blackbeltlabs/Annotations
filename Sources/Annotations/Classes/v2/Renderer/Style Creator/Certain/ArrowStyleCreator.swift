import Foundation

class ArrowStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Arrow) -> LayerUISettings {
    .init(lineWidth: 0,
          strokeColor: figure.colour.cgColor,
          fillColor: figure.colour.cgColor)
  }
}
