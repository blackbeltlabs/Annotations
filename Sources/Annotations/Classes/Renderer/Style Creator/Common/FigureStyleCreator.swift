import CoreGraphics

protocol FigureStyleCreator {
  associatedtype F: Figure
  func createStyle(for figure: F) -> LayerUISettings
}
