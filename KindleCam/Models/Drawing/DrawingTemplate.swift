//
//  DrawingTemplate.swift
//  KindleCam
//
//  SwiftData @Model representing bundled or seeded drawing templates.
//

import Foundation
import SwiftData

@Model
public final class DrawingTemplate {
    public var id: UUID
    public var category: String
    public var title: String
    
    @Attribute(.externalStorage)
    public var thumbnail: Data?
    
    @Attribute(.externalStorage)
    public var outlineData: Data?
    
    public var difficulty: DifficultyLevel

    public init(
        id: UUID = UUID(),
        category: String = "",
        title: String = "",
        thumbnail: Data? = nil,
        outlineData: Data? = nil,
        difficulty: DifficultyLevel = .easy
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.thumbnail = thumbnail
        self.outlineData = outlineData
        self.difficulty = difficulty
    }
}
