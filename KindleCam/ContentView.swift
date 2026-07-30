//
//  ContentView.swift
//  KindleCam
//
//  Main entry point view presenting the KindleCam Home Screen.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeScreenView()
    }
}

#Preview {
    ContentView()
        .modelContainer(AppModelContainer.previewContainer())
}
