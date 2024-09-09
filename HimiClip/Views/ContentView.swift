//
//  ContentView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var clipHistory: [ClipEntry] = []
    
    var body: some View {
        TabView {
            ClipEditorView(clipHistory: $clipHistory)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Editor")
                }

            ClipHistoryView(clipHistory: $clipHistory)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

