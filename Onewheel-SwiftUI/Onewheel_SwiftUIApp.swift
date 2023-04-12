//
//  Onewheel_SwiftUIApp.swift
//  Shared
//
//  Created by Adin Ackerman on 8/30/22.
//

import SwiftUI
import BackgroundTasks

@main
struct Onewheel_SwiftUIApp: App {
    @StateObject var vesc: VESC = VESC()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vesc)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "bt-periodic")
        request.earliestBeginDate = .now
        try? BGTaskScheduler.shared.submit(request)
    }
}
