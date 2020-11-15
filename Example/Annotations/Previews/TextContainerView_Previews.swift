import AppKit
import Annotations

// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct TextContainerViewPreview: NSViewRepresentable {
  let style: TextParams
  let text: String

  func makeNSView(context: Context) -> TextContainerView {
    TextContainerView(frame: .zero,
                      text: text,
                      textParams: style,
                      legibilityEffectEnabled: false,
                      enableEmojies: true)
  }

  func updateNSView(_ view: TextContainerView, context: Context) {
  }
}

struct ExampleScreenshots {
    static var github = #imageLiteral(resourceName: "github_screenshot")
    static var landingPage = #imageLiteral(resourceName: "browser_screenshot")
    static var browserApp = #imageLiteral(resourceName: "browser_app_screenshot")
    static var figma = #imageLiteral(resourceName: "figma_screenshot")
}

@available(OSX 10.15.0, *)
extension TextModel: Identifiable {
  public var id: Int {
    index
  }
}

@available(OSX 10.15.0, *)
struct TextContainerView_Previews: PreviewProvider {
  
  // a color to use in all previews if no custom color is passed
  static var defaultColor: NSColor? = NSColor.color(from: ModelColor.orange)
    
  
  static let texts: [TextModel] = {
    let url = Bundle.main.url(forResource: "texts", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try! decoder.decode([TextModel].self, from: data)
  }()
    
  
  static var previews: some View {
    ForEach(texts) { textModel in
      preview(with: textModel)
    }
  }
  
  static func preview(with model: TextModel) -> some View {
    TextContainerViewPreview(style: model.style,
                             text: model.text)
      .background(Image(nsImage: ExampleScreenshots.figma))
      .previewLayout(.fixed(width: 300.0, height: 200.0))
  }
}
#endif

extension NSColor {
 func color(from textColor: ModelColor) -> NSColor {
  return NSColor(red: textColor.red,
                 green: textColor.green,
                 blue: textColor.blue,
                 alpha: textColor.alpha)
  }
}
