//
//  StoryTask.swift
//  KindleCam
//
//  SwiftData @Model representing an interactive task inside a camera story session.
//  Each task has a story segment (the narrative leading into it), an interaction type,
//  and a JSON-encoded payload carrying task-specific data (quiz options, counts, etc.).
//

import Foundation
import SwiftData

@Model
public final class StoryTask {
    public var taskId: UUID
    public var orderIndex: Int
    public var taskType: TaskType
    public var title: String
    /// The story narrative segment shown before this task.
    public var storySegment: String
    /// Named `taskDescription` to prevent SwiftData collision with NSObject's `description` property.
    public var taskDescription: String
    public var difficulty: DifficultyLevel
    public var completed: Bool
    public var completionTime: Date?
    /// JSON-encoded TaskPayload for task-specific data (quiz options, correct counts, etc.).
    public var payloadJSON: String
    
    public var story: CameraStory?
    
    public var id: UUID { taskId }
    
    /// Decode the typed TaskPayload from the stored JSON.
    @MainActor
    public var payload: TaskPayload? {
        guard let data = payloadJSON.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TaskPayload.self, from: data)
    }

    public init(
        taskId: UUID = UUID(),
        orderIndex: Int = 0,
        taskType: TaskType = .quizQuestion,
        title: String = "",
        storySegment: String = "",
        taskDescription: String = "",
        difficulty: DifficultyLevel = .easy,
        completed: Bool = false,
        completionTime: Date? = nil,
        payloadJSON: String = "{}",
        story: CameraStory? = nil
    ) {
        self.taskId = taskId
        self.orderIndex = orderIndex
        self.taskType = taskType
        self.title = title
        self.storySegment = storySegment
        self.taskDescription = taskDescription
        self.difficulty = difficulty
        self.completed = completed
        self.completionTime = completionTime
        self.payloadJSON = payloadJSON
        self.story = story
    }
}
