//
//  XcleaControlApp.swift
//  XcleaControl
//
//  Created by Your Name on 23.10.2026.
//

import SwiftUI

@main
struct XcleaControlApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var connectionService = ConnectionService.shared
    @StateObject private var discoveryService = DeviceDiscoveryService.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(connectionService)
                .environmentObject(discoveryService)
                .task {
                    await discoveryService.startDiscovery()
                }
        }
    }
}
