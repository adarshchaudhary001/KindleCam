//
//  CameraStory.swift
//  KindleCam
//
//  Root @Model record for one "point the camera, get a story" session.
//

import Foundation
import SwiftData

@Model
public final class CameraStory {
    public var id: UUID
    public var title: String
    public var creationDate: Date
    /// The story text generated from Foundation Models.
    public var generatedStory: String
    
    /// Embedded detection records from the camera session.
    public var capturedObjects: [CapturedObject]
    /// Embedded evaluation log of correct actions.
    public var correctActions: [ActionRecord]
    /// Embedded log of performed actions.
    public var performedActions: [ActionRecord]
    
    /// Real relationship to interactive tasks with cascade delete.
    @Relationship(deleteRule: .cascade, inverse: \StoryTask.story)
    public var tasks: [StoryTask]

    public init(
        id: UUID = UUID(),
        title: String = "",
        creationDate: Date = Date(),
        generatedStory: String = "",
        capturedObjects: [CapturedObject] = [],
        correctActions: [ActionRecord] = [],
        performedActions: [ActionRecord] = [],
        tasks: [StoryTask] = []
    ) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.generatedStory = generatedStory
        self.capturedObjects = capturedObjects
        self.correctActions = correctActions
        self.performedActions = performedActions
        self.tasks = tasks
    }
}
