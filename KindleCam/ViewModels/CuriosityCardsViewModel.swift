//
//  CuriosityCardsViewModel.swift
//  KindleCam
//
//  ViewModel orchestrating the Curiosity Cards feature.
//  Manages question bank seeding, Daily Wonder selection, answered/favorite state,
//  and category filtering.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
public final class CuriosityCardsViewModel {
    
    // MARK: - Published State
    
    public var allQuestions: [CuriosityQuestion] = []
    public var dailyWonderQuestion: CuriosityQuestion?
    public var curiosityQuestions: [CuriosityQuestion] = []
    public var selectedCategory: String = "All"
    
    public var answeredQuestionIds: Set<UUID> = []
    public var favoriteQuestionIds: Set<UUID> = []
    
    public var isLoading: Bool = false
    
    // MARK: - Services & Context
    
    private let repository = CuriosityRepository()
    private let answerService = CuriosityAnswerService()
    private var modelContext: ModelContext?
    
    public init() {}
    
    /// Set the SwiftData ModelContext and trigger initial data load.
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadData()
    }
    
    /// Seed JSON if needed, load all questions and interactions from SwiftData.
    public func loadData() {
        guard let modelContext else { return }
        
        isLoading = true
        
        // 1. Seed SwiftData from JSON if needed
        repository.seedQuestionsIfNeeded(modelContext: modelContext)
        
        // 2. Fetch all questions from SwiftData
        let questionDescriptor = FetchDescriptor<CuriosityQuestion>()
        allQuestions = (try? modelContext.fetch(questionDescriptor)) ?? []
        
        // If SwiftData fetch failed, load fallback questions directly
        if allQuestions.isEmpty {
            allQuestions = repository.loadBundledJSONQuestions()
        }
        
        // 3. Fetch user interactions from SwiftData
        let interactionDescriptor = FetchDescriptor<QuestionInteraction>()
        let interactions = (try? modelContext.fetch(interactionDescriptor)) ?? []
        
        answeredQuestionIds = Set(
            interactions
                .filter { $0.viewedDate != nil }
                .map { $0.questionId }
        )
        
        favoriteQuestionIds = Set(
            interactions
                .filter { $0.isFavorite }
                .map { $0.questionId }
        )
        
        // 4. Compute Daily Wonder
        dailyWonderQuestion = repository.getDailyWonder(from: allQuestions)
        
        // 5. Compute Curiosity List
        updateCuriosityList()
        
        isLoading = false
    }
    
    /// Filter questions based on selected category.
    public func selectCategory(_ category: String) {
        selectedCategory = category
        updateCuriosityList()
    }
    
    /// Compute 4–6 variety questions prioritizing unanswered ones.
    public func updateCuriosityList() {
        curiosityQuestions = repository.getCuriosityList(
            from: allQuestions,
            answeredIds: answeredQuestionIds,
            excludingId: dailyWonderQuestion?.id,
            categoryFilter: selectedCategory,
            limit: 5
        )
    }
    
    /// Mark a question as answered in SwiftData.
    public func markAnswered(_ questionId: UUID) {
        guard let modelContext else { return }
        
        answeredQuestionIds.insert(questionId)
        
        // Fetch existing interaction or create new
        let descriptor = FetchDescriptor<QuestionInteraction>(
            predicate: #Predicate { $0.questionId == questionId }
        )
        
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            existing.viewedDate = Date()
        } else {
            let interaction = QuestionInteraction(questionId: questionId, viewedDate: Date())
            modelContext.insert(interaction)
        }
        
        try? modelContext.save()
        updateCuriosityList()
    }
    
    /// Toggle favorite status of a question.
    public func toggleFavorite(_ questionId: UUID) {
        guard let modelContext else { return }
        
        let isFav = favoriteQuestionIds.contains(questionId)
        if isFav {
            favoriteQuestionIds.remove(questionId)
        } else {
            favoriteQuestionIds.insert(questionId)
        }
        
        let descriptor = FetchDescriptor<QuestionInteraction>(
            predicate: #Predicate { $0.questionId == questionId }
        )
        
        if let existing = (try? modelContext.fetch(descriptor))?.first {
            existing.isFavorite = !isFav
        } else {
            let interaction = QuestionInteraction(questionId: questionId, isFavorite: !isFav)
            modelContext.insert(interaction)
        }
        
        try? modelContext.save()
    }
    
    /// Check if a question has been answered.
    public func isAnswered(_ questionId: UUID) -> Bool {
        answeredQuestionIds.contains(questionId)
    }
    
    /// Check if a question is favorited.
    public func isFavorite(_ questionId: UUID) -> Bool {
        favoriteQuestionIds.contains(questionId)
    }
    
    /// Generate answer for a question using CuriosityAnswerService.
    public func fetchAnswer(for question: CuriosityQuestion) async -> String {
        await answerService.generateAnswer(for: question)
    }
}
