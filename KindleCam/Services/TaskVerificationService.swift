//
//  TaskVerificationService.swift
//  KindleCam
//
//  Validates the child's action against the expected correct answer for each task type.
//  Returns a result with success/failure and an encouraging feedback message.
//

import Foundation

/// Result of verifying a child's action on a story task.
public struct TaskVerificationResult: Sendable {
    public let isCorrect: Bool
    public let feedbackMessage: String
    
    public init(isCorrect: Bool, feedbackMessage: String) {
        self.isCorrect = isCorrect
        self.feedbackMessage = feedbackMessage
    }
}

/// Validates child actions for each interactive task type.
public final class TaskVerificationService: Sendable {
    
    private static let successMessages = [
        "Amazing job! ⭐",
        "You're so smart! 🌟",
        "Wonderful! Keep going! 🎉",
        "Great thinking! 💫",
        "You did it! 🏆"
    ]
    
    private static let encourageMessages = [
        "Almost! Try again! 💪",
        "So close! Give it another try! 🌈",
        "Not quite, but you're doing great! ⭐",
        "Hmm, let's try once more! 😊"
    ]
    
    public init() {}
    
    /// Verify a quiz answer. `selectedIndex` is the child's chosen option index.
    public func verifyQuiz(selectedIndex: Int, payload: TaskPayload) -> TaskVerificationResult {
        guard case .quiz(_, let correctIndex) = payload else {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        }
        
        if selectedIndex == correctIndex {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        } else {
            return TaskVerificationResult(isCorrect: false, feedbackMessage: Self.randomEncouragement())
        }
    }
    
    /// Verify a count answer. `childCount` is the number the child selected.
    public func verifyCount(childCount: Int, payload: TaskPayload) -> TaskVerificationResult {
        guard case .count(let correctCount, _) = payload else {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        }
        
        if childCount == correctCount {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        } else {
            return TaskVerificationResult(isCorrect: false, feedbackMessage: Self.randomEncouragement())
        }
    }
    
    /// Verify a tap task. `tappedCount` is how many targets the child tapped.
    public func verifyTap(tappedCount: Int, payload: TaskPayload) -> TaskVerificationResult {
        guard case .tap(let targetCount, _) = payload else {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        }
        
        if tappedCount >= targetCount {
            return TaskVerificationResult(isCorrect: true, feedbackMessage: Self.randomSuccess())
        } else {
            return TaskVerificationResult(isCorrect: false, feedbackMessage: Self.randomEncouragement())
        }
    }
    
    private static func randomSuccess() -> String {
        successMessages.randomElement() ?? "Great job! ⭐"
    }
    
    private static func randomEncouragement() -> String {
        encourageMessages.randomElement() ?? "Try again! 💪"
    }
}
