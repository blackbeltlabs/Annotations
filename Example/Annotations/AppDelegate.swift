//
//  AppDelegate.swift
//  Annotations
//
//  Created by Mirko Kiefer on 03/21/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let vc = PlaygroundControllerAssembler.assemble(with: NSImage(named: "catalina")!,
                                                    jsonURL: Bundle.jsonURL("test_drawing.json"),
                                                    withControls: true)
    vc.showWindow(self)
    vc.window?.makeKeyAndOrderFront(self)
    vc.window?.center()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

