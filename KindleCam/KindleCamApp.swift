//
//  KindleCamApp.swift
//  KindleCam
//
//  Created by Aakash Singh Ranswal on 28/07/26.
//

import SwiftUI
import SwiftData

@main
struct KindleCamApp: App {
    var sharedModelContainer: ModelContainer = AppModelContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

