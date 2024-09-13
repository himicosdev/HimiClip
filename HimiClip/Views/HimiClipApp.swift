//
//  HimiClipApp.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

let globalToastManager = ToastManager()
let authManager = AuthenticationManager()

@main
struct HimiClipApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var appState = AppState()

    init() {
        // zh-Hans
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(appState)
            } else {
                AuthView()
            }
        }
        .environmentObject(authManager)
    }
}
