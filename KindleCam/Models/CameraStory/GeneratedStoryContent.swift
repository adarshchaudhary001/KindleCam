//
//  GeneratedStoryContent.swift
//  KindleCam
//
//  DTOs used to map structured output from Foundation Models into SwiftData models.
//

import Foundation

/// DTO for Foundation Model structured story outputs.
public struct GeneratedStoryContent: Codable, Sendable {
    public let story: String
    public let tasks: [GeneratedTaskContent]
    
    public init(story: String, tasks: [GeneratedTaskContent]) {
        self.story = story
        self.tasks = tasks
    }
}

/// DTO for Foundation Model structured task outputs.
public struct GeneratedTaskContent: Codable, Sendable {
    public let title: String
    public let taskDescription: String
    public let taskType: TaskType
    public let difficulty: DifficultyLevel
    
    public init(title: String, taskDescription: String, taskType: TaskType, difficulty: DifficultyLevel) {
        self.title = title
        self.taskDescription = taskDescription
        self.taskType = taskType
        self.difficulty = difficulty
    }
}
