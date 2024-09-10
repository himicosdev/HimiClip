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
                    Text(NSLocalizedString("EDITOR", comment: ""))
                }

            ClipHistoryView(clipHistory: $clipHistory)
                .tabItem {
                    Image(systemName: "clock")
                    Text(NSLocalizedString("HISTORY", comment: ""))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

