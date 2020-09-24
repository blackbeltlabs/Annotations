import Cocoa

struct FontSnapshot {
  let name: String
  let size: CGFloat
}

class HistoryTrackingHelper {
  private(set) var fontSnapshot: FontSnapshot?
  private(set) var textSnapshot: String = ""
  
  
  func makeFontSnapshot(font: NSFont) {
    fontSnapshot =  FontSnapshot(name: font.fontName,
                                 size: font.pointSize)
  }
  
  func makeTextSnapshot(text: String) {
    self.textSnapshot = text
  }

}
