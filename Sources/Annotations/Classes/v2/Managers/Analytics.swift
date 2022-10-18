import Foundation

protocol AnalyticsDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
}

public final class Analytics {
  weak var dataSource: AnalyticsDataSource?
  
  public var totalAnnotationsCount: Int {
    dataSource?.annotations.count ?? 0
  }
  
  public var allAnnotationTypes: [String] {
    guard let annotations = dataSource?.annotations else { return [] }
    return Self.allAnnotationTypes(for: annotations)
  }
  
  // calculate all color selection types and return their numbers as an array of colors that is passed
  public func allColorTypes(with colors: [ModelColor]) -> [Int] {
    guard let annotations = dataSource?.annotations else { return [] }
    return Self.calculateAllColorSelectionTypes(for: annotations,
                                                colors: colors)
  }

  private static func allAnnotationTypes(for annotations: [AnnotationModel]) -> [String] {
    var names = Set<String>()
    
    for annotation in annotations {
      names.insert(Self.analyticsName(for: annotation))
    }
    
    return Array(names)
  }
  
  // calculate all color selection types and return their numbers as an array of colors that is passed
  static func calculateAllColorSelectionTypes(for annotations: [AnnotationModel],
                                              colors: [ModelColor]) -> [Int] {
    var colorsSet = Set<Int>()
 
    let allModelColors = annotations.map(\.color)
    
    for color in allModelColors {
      if let index = colors.firstIndex(of: color) {
        colorsSet.insert(index)
        // all possible colors are already on canvas, no need more loop iterations
        if colorsSet.count == colors.count {
          break
        }
      }
    }
    
    var array = Array(colorsSet).sorted()
    
    for (index, value) in array.enumerated() {
      array[index] = value + 1
    }
    
    return array
  }
  

  static func analyticsName(for model: AnnotationModel) -> String {
    switch model {
    case is Arrow:
      return "Arrow"
    case let rect as Rect:
      switch rect.rectType {
      case .regular:
        return "Rectangle"
      case .highlight:
        return "Highlight"
      case .obfuscate:
        return "Obfuscate"
      }
    case is Pen:
      return "Pen"
    case is Number:
      return "Number"
    case is Text:
      return "Text"
    default:
      return "Unknown"
    }
  }
}
