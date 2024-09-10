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
    init() {
        // zh-Hans
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
