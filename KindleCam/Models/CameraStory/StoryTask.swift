//
//  StoryTask.swift
//  KindleCam
//
//  SwiftData @Model representing an interactive task inside a camera story session.
//  Has mutable state (completed, completionTime) and stands as its own database table for cross-story queries.
//

import Foundation
import SwiftData

@Model
public final class StoryTask {
    public var taskId: UUID
    public var taskType: TaskType
    public var title: String
    /// Named `taskDescription` to prevent SwiftData collision with NSObject's `description` property.
    public var taskDescription: String
    public var difficulty: DifficultyLevel
    public var completed: Bool
    public var completionTime: Date?
    
    public var story: CameraStory?
    
    public var id: UUID { taskId }

    public init(
        taskId: UUID = UUID(),
        taskType: TaskType = .cameraScan,
        title: String = "",
        taskDescription: String = "",
        difficulty: DifficultyLevel = .easy,
        completed: Bool = false,
        completionTime: Date? = nil,
        story: CameraStory? = nil
    ) {
        self.taskId = taskId
        self.taskType = taskType
        self.title = title
        self.taskDescription = taskDescription
        self.difficulty = difficulty
        self.completed = completed
        self.completionTime = completionTime
        self.story = story
    }
}
