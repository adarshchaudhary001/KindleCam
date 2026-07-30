//
//  CuriosityQuestion.swift
//  KindleCam
//
//  SwiftData @Model representing curiosity questions.
//  Static content authored for children; tags are stored natively as primitive string array.
//

import Foundation
import SwiftData

@Model
public final class CuriosityQuestion {
    public var id: UUID
    public var category: String
    public var question: String
    public var answer: String
    /// Free-form text for flexible age range bands (e.g. "3-5", "6-8").
    public var ageGroup: String
    /// Native SwiftData support for primitive arrays.
    public var tags: [String]

    public init(
        id: UUID = UUID(),
        category: String = "",
        question: String = "",
        answer: String = "",
        ageGroup: String = "",
        tags: [String] = []
    ) {
        self.id = id
        self.category = category
        self.question = question
        self.answer = answer
        self.ageGroup = ageGroup
        self.tags = tags
    }
}
