//
//  ActionRecord.swift
//  KindleCam
//
//  Embedded Codable struct representing correct or performed actions within a story session.
//

import Foundation

/// Embedded log entry for actions performed or evaluated during a story session.
public struct ActionRecord: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    /// Optional soft reference to related StoryTask.
    public var taskId: UUID?
    public var actionDescription: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        taskId: UUID? = nil,
        actionDescription: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.taskId = taskId
        self.actionDescription = actionDescription
        self.timestamp = timestamp
    }
}
