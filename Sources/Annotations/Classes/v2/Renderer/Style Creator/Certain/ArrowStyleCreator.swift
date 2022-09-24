import Foundation

class ArrowStyleCreator: FigureStyleCreator {
  func createStyle(for figure: Arrow) -> LayerUISettings {
    .init(lineWidth: 0,
          strokeColor: figure.color.cgColor,
          fillColor: figure.color.cgColor)
  }
}
