//
//  QuestionInteraction.swift
//  KindleCam
//
//  SwiftData @Model tracking user interaction with curiosity questions (progress, favorites).
//  Separated from static content so content updates via JSON don't overwrite user interaction history.
//

import Foundation
import SwiftData

@Model
public final class QuestionInteraction {
    public var questionId: UUID
    public var viewedDate: Date?
    public var isFavorite: Bool
    /// Persisted AI-generated answer so the same answer is displayed every time.
    public var cachedAnswer: String?

    public init(
        questionId: UUID = UUID(),
        viewedDate: Date? = nil,
        isFavorite: Bool = false,
        cachedAnswer: String? = nil
    ) {
        self.questionId = questionId
        self.viewedDate = viewedDate
        self.isFavorite = isFavorite
        self.cachedAnswer = cachedAnswer
    }
}
