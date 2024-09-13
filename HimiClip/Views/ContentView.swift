//
//  ContentView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            ClipEditorView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text(NSLocalizedString("EDITOR", comment: ""))
                }

            ClipHistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text(NSLocalizedString("HISTORY", comment: ""))
                }
        }
    }
}
