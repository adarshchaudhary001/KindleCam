//
//  CuriosityAnswerService.swift
//  KindleCam
//
//  Service utilizing Apple's Foundation Models (iOS 26+) to generate simple,
//  engaging, child-friendly explanations for curiosity questions.
//  Falls back gracefully to the pre-authored JSON answer if AI is unavailable.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Generates child-friendly answers for curiosity questions using Apple Foundation Models.
public final class CuriosityAnswerService: Sendable {
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static let systemInstructions = """
    You are a warm, magical science teacher for children ages 3-8.
    
    Rules:
    - Answer questions in 2-3 short, simple sentences.
    - Generate ONLY the answer, do not repeat the question.
    - Use simple words and fun analogies suitable for a young child.
    - Be encouraging, fascinating, and positive.
    - Keep it short (maximum 50 words).
    """
    #endif

    public init() {}
    
    /// Generates a simple, engaging answer for the given question using Foundation Models.
    /// Falls back to `question.answer` if AI generation fails or is unavailable.
    public func generateAnswer(for question: CuriosityQuestion) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if let aiAnswer = await generateWithFoundationModels(questionText: question.question) {
                return aiAnswer
            }
        }
        #endif
        
        // Fallback to pre-authored JSON answer
        return question.answer
    }
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(questionText: String) async -> String? {
        let model = SystemLanguageModel.default
        guard model.isAvailable else {
            print("[CuriosityAnswerService] SystemLanguageModel is unavailable, falling back to JSON answer.")
            return nil
        }
        
        print("Question is: \(questionText)")
        let prompt = "Answer this question: \"\(questionText)\""
        
        do {
            // Instantiate session with system instructions
            let session = LanguageModelSession(instructions: Self.systemInstructions)
            let response = try await session.respond(to: prompt)
            let answerText = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !answerText.isEmpty {
                return answerText
            }
        } catch {
            let errorString = String(describing: error)
            print(errorString)
            if errorString.contains("unsupportedLanguageOrLocale") || errorString.contains("Unsupported language") {
                print("[CuriosityAnswerService] Apple Foundation Models requires Primary Language set to English (en_US). Using pre-authored JSON fallback answer.")
            } else {
                print("[CuriosityAnswerService] Foundation Models generation error: \(error)")
            }
        }
        
        return nil
    }
    #endif
}
