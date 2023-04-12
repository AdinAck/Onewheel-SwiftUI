//
//  Onewheel_SwiftUI_MenubarApp.swift
//  Onewheel-SwiftUI-Menubar
//
//  Created by Adin Ackerman on 12/6/22.
//

import SwiftUI

@main
struct Onewheel_SwiftUI_MenubarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Text("Close this window.")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .frame(width: 300, height: 300)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var vesc: VESC!
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        self.vesc = VESC()
        
        DispatchQueue.global().async {
            while true {
                if self.vesc.loaded {
                    self.vesc.getValues(type: .COMM_GET_VALUES)
                    self.vesc.getValues(type: .COMM_GET_DECODED_BALANCE)
                }
                
                DispatchQueue.main.async {
                    self.updateStatus()
                }
                
                Thread.sleep(forTimeInterval: 1)
            }
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "engine.combustion.fill", accessibilityDescription: nil)
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 300, height: 120)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView(vesc: self.vesc))
    }
    
    private func updateStatus() {
        if let statusButton = statusItem?.button {
            if self.vesc.loaded {
                statusButton.appearsDisabled = false
            } else {
                statusButton.appearsDisabled = true
            }
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}
