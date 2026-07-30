//
//  TaskType.swift
//  KindleCam
//
//  Enum defining types of interactive tasks inside a story.
//

import Foundation

/// Types of interactive tasks generated within a CameraStory.
public enum TaskType: String, Codable, CaseIterable, Identifiable, Sendable {
    case countObjects
    case tapObjects
    case dragObjects
    case drawSomething
    case speakPhrase
    case findAnotherObject
    case cameraScan
    case quizQuestion
    
    public var id: String { rawValue }
}
