//
//  ssh_log_viewerApp.swift
//  ssh-log-viewer
//
//  Created by RC on 03/03/25.
//

import SwiftUI

@main
struct ssh_log_viewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            //SidebarCommands()
            //ToolbarCommands()
            HostCommands()
        }
    }
}
