//
//  DifficultyLevel.swift
//  KindleCam
//
//  Shared enum representing difficulty levels across tasks and drawing templates.
//

import Foundation

/// Represents difficulty level across tasks and drawing templates.
public enum DifficultyLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case easy
    case medium
    case hard
    
    public var id: String { rawValue }
}
