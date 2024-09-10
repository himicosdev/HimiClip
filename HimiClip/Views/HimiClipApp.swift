//
//  HimiClipApp.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

let globalToastManager = ToastManager()

@main
struct HimiClipApp: App {
    @State private var isAuthenticated = false

    init() {
        // zh-Hans
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 检查是否有存储的token
        if UserDefaults.standard.string(forKey: "userToken") != nil {
            isAuthenticated = true
        }
    }

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
            } else {
                AuthView()
                    .onReceive(NotificationCenter.default.publisher(for: .userDidAuthenticate)) { _ in
                        isAuthenticated = true
                    }
            }
        }
    }
}

extension Notification.Name {
    static let userDidAuthenticate = Notification.Name("userDidAuthenticate")
}
