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

    public init(
        questionId: UUID = UUID(),
        viewedDate: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.questionId = questionId
        self.viewedDate = viewedDate
        self.isFavorite = isFavorite
    }
}
