import Cocoa

class HistoryTrackingHelper {
  private(set) var textSnapshot: String = ""
  
  func makeTextSnapshot(text: String) {
    self.textSnapshot = text
  }
}
