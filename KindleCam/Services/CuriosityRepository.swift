//
//  CuriosityRepository.swift
//  KindleCam
//
//  Service managing question bank loading from JSON, SwiftData seeding,
//  deterministic Daily Wonder calculation, and variety question selection.
//

import Foundation
import SwiftData

/// Manages curiosity questions loading, seeding, and deterministic daily selection.
public final class CuriosityRepository: Sendable {
    
    public init() {}
    
    /// Seed SwiftData with bundled JSON questions if empty.
    @MainActor
    public func seedQuestionsIfNeeded(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CuriosityQuestion>()
        let existingCount = (try? modelContext.fetchCount(fetchDescriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        let loadedQuestions = loadBundledJSONQuestions()
        for q in loadedQuestions {
            modelContext.insert(q)
        }
        try? modelContext.save()
    }
    
    /// Loads questions directly from bundled JSON file.
    public func loadBundledJSONQuestions() -> [CuriosityQuestion] {
        guard let url = Bundle.main.url(forResource: "CuriosityQuestions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return fallbackJSONQuestions()
        }
        
        struct DTO: Codable {
            let id: String
            let category: String
            let question: String
            let answer: String
            let ageGroup: String
            let tags: [String]
        }
        
        guard let dtos = try? JSONDecoder().decode([DTO].self, from: data) else {
            return fallbackJSONQuestions()
        }
        
        return dtos.map { dto in
            CuriosityQuestion(
                id: UUID(uuidString: dto.id) ?? UUID(),
                category: dto.category,
                question: dto.question,
                answer: dto.answer,
                ageGroup: dto.ageGroup,
                tags: dto.tags
            )
        }
    }
    
    /// Returns the deterministic "Daily Wonder" question for today based on calendar date.
    /// Remains identical throughout the day, changes the next day, works 100% offline.
    public func getDailyWonder(from questions: [CuriosityQuestion]) -> CuriosityQuestion? {
        guard !questions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        
        let deterministicIndex = (dayOfYear + year * 7) % questions.count
        return questions[deterministicIndex]
    }
    
    /// Returns a list of 4–6 variety questions, prioritizing unanswered questions.
    public func getCuriosityList(
        from questions: [CuriosityQuestion],
        answeredIds: Set<UUID>,
        excludingId: UUID?,
        categoryFilter: String? = nil,
        limit: Int = 5
    ) -> [CuriosityQuestion] {
        let pool = questions.filter { q in
            if let excludingId, q.id == excludingId { return false }
            if let categoryFilter, !categoryFilter.isEmpty, categoryFilter != "All" {
                return q.category.lowercased() == categoryFilter.lowercased()
            }
            return true
        }
        
        let unanswered = pool.filter { !answeredIds.contains($0.id) }
        let answered = pool.filter { answeredIds.contains($0.id) }
        
        let combined = unanswered + answered
        return Array(combined.prefix(limit))
    }
    
    // MARK: - Hardcoded Fallback Seed Questions
    
    private func fallbackJSONQuestions() -> [CuriosityQuestion] {
        return [
            CuriosityQuestion(
                category: "Space",
                question: "Why is the sky blue?",
                answer: "Sunlight is made of all rainbow colors. Blue light scatters around Earth's air the most, making the sky look blue!",
                ageGroup: "3-8",
                tags: ["sky", "sun"]
            ),
            CuriosityQuestion(
                category: "Space",
                question: "Why do stars twinkle?",
                answer: "Moving air in Earth's atmosphere bends starlight back and forth, making stars sparkle and twinkle!",
                ageGroup: "3-8",
                tags: ["stars"]
            ),
            CuriosityQuestion(
                category: "Animals",
                question: "How do birds fly?",
                answer: "Birds have light hollow bones and curved wings that push air down to lift them up into the sky!",
                ageGroup: "3-8",
                tags: ["birds"]
            ),
            CuriosityQuestion(
                category: "Nature",
                question: "Why is the ocean salty?",
                answer: "Rain washes tiny salts from land into rivers and oceans. Water evaporates, leaving salt behind!",
                ageGroup: "3-8",
                tags: ["ocean"]
            ),
            CuriosityQuestion(
                category: "Human Body",
                question: "Why do we have fingerprints?",
                answer: "Fingerprints have tiny ridges that help us grip toys and cups without slipping!",
                ageGroup: "3-8",
                tags: ["fingerprints"]
            )
        ]
    }
}
