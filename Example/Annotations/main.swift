import Cocoa

private func runApplication(application: NSApplication,
                            delegate: NSObject.Type?,
                            bundle: Bundle) {
    application.delegate = delegate?.init() as? NSApplicationDelegate
    application.run()
}

runApplication(application: NSApplication.shared,
               delegate: AppDelegate.self,
               bundle: .main)
