import Foundation

@MainActor
protocol AnalyticsDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
}

// This class return some analytics data for the current annotations models
// that could be retrieved in the app that uses Annotations framework
@MainActor
public final class Analytics {
  weak var dataSource: AnalyticsDataSource?
  
  // return total count of annotations on the canvas
  public var totalAnnotationsCount: Int {
    dataSource?.annotations.count ?? 0
  }
  
  // string representations of unique annotation types that are on the canvas
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

  static func allAnnotationTypes(for annotations: [AnnotationModel]) -> [String] {
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
      return "analytics_name_arrow".localized
    case let rect as Rect:
      switch rect.rectType {
      case .regular:
        return "analytics_name_rect".localized
      case .highlight:
        return "analytics_name_highlight".localized
      case .obfuscate:
        return "analytics_name_obfuscate".localized
      }
    case is Pen:
      return "analytics_name_pen".localized
    case is Number:
      return "analytics_name_number".localized
    case is Text:
      return "analytics_name_text".localized
    default:
      return "analytics_name_unknown".localized
    }
  }
}
