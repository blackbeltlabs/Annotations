import Foundation

class Logger {
    let isDebug: Bool
    
    init(isDebug: Bool) {
        self.isDebug = isDebug
    }
    
    public func debug(_ string: String) {
        guard isDebug else { return }
        print("🕛 💚 \(string)")
    }

    public func error(_ string: String) {
        guard isDebug else { return }
        print("🕛 ❤️ \(string)")
    }

    public func warning(_ string: String) {
        guard isDebug else { return }
        print("🕛 💛 \(string)")
    }
}
