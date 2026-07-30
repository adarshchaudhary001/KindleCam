//
//  ModelContainer+Setup.swift
//  KindleCam
//
//  Central ModelContainer setup following offline-first design principles.
//  Provides single source of truth for app container and preview/testing instances.
//

import Foundation
import SwiftData

@MainActor
public enum AppModelContainer {
    /// Full SwiftData schema for the KindleCam application.
    public static let schema = Schema([
        CameraStory.self,
        StoryTask.self,
        SavedDrawing.self,
        DrawingTemplate.self,
        CuriosityQuestion.self,
        QuestionInteraction.self
    ])
    
    /// Shared production container created at app launch.
    public static let shared: ModelContainer = {
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create AppModelContainer: \(error)")
        }
    }()
    
    /// Creates an in-memory ModelContainer for SwiftUI previews and unit tests.
    public static func previewContainer() -> ModelContainer {
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create preview AppModelContainer: \(error)")
        }
    }
}
