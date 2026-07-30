//
//  StoryGeneratorService.swift
//  KindleCam
//
//  Generates interactive stories from detected objects using Foundation Models (iOS 26+).
//  Falls back to dynamic category-aware template stories when Foundation Models are unavailable.
//
//  The service produces GeneratedStoryContent containing:
//  - A child-friendly narrative
//  - 3 interactive tasks with typed payloads (quiz, count, tap) tailored to detected objects.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Generates a child-friendly story and interactive tasks from captured objects.
public final class StoryGeneratorService: Sendable {
    
    public init() {}
    
    /// Generate a story from detected objects.
    /// Attempts Foundation Models first, falls back to dynamic templates.
    public func generateStory(from objects: [CapturedObject]) async -> GeneratedStoryContent {
        let objectLabels = objects.map { $0.label }
        
        #if canImport(FoundationModels)
        if let aiStory = await generateWithFoundationModels(objectLabels: objectLabels) {
            return aiStory
        }
        #endif
        
        // Fallback to dynamic category-aware story generation
        return generateTemplateStory(objectLabels: objectLabels)
    }
    
    // MARK: - Foundation Models Integration
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(objectLabels: [String]) async -> GeneratedStoryContent? {
        let objectList = objectLabels.joined(separator: ", ")
        let prompt = """
        You are a children's storyteller for ages 3-7. Create a short, magical adventure story \
        featuring these objects: \(objectList).
        
        The story should be 3-4 sentences long, playful and encouraging.
        
        Then create exactly 3 interactive tasks for the child. Each task must be one of these types:
        - quizQuestion: A multiple-choice question with 3 options
        - countObjects: Ask the child to count something
        - tapObjects: Ask the child to tap on items
        
        Respond in this exact JSON format:
        {
            "title": "story title",
            "story": "the full story text",
            "tasks": [
                {
                    "title": "task title",
                    "storySegment": "short story segment leading into this task",
                    "taskDescription": "what the child needs to do",
                    "taskType": "quizQuestion",
                    "difficulty": "easy",
                    "payload": {
                        "type": "quiz",
                        "options": ["option1", "option2", "option3"],
                        "correctAnswerIndex": 0
                    }
                }
            ]
        }
        
        For countObjects tasks, payload should be: {"type": "count", "correctCount": 3, "objectLabel": "stars"}
        For tapObjects tasks, payload should be: {"type": "tap", "targetCount": 4, "objectLabel": "butterflies"}
        
        Keep language simple. Use short sentences. Be encouraging and fun.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            let responseText = response.content
            
            if let jsonData = extractJSON(from: responseText),
               let parsed = try? JSONDecoder().decode(
                    GeneratedStoryContent.self,
                    from: jsonData
               ) {
                return parsed
            }
        } catch {
            print("[StoryGeneratorService] Foundation Models error: \(error)")
        }
        
        return nil
    }
    
    /// Extract JSON object from a text response that may contain markdown fences.
    private func extractJSON(from text: String) -> Data? {
        var jsonString = text
        
        if let startRange = jsonString.range(of: "```json") {
            jsonString = String(jsonString[startRange.upperBound...])
        } else if let startRange = jsonString.range(of: "```") {
            jsonString = String(jsonString[startRange.upperBound...])
        }
        if let endRange = jsonString.range(of: "```") {
            jsonString = String(jsonString[..<endRange.lowerBound])
        }
        
        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)
    }
    #endif
    
    // MARK: - Dynamic Template Story Generation
    
    /// Generates a story tailored specifically to the detected objects.
    private func generateTemplateStory(objectLabels: [String]) -> GeneratedStoryContent {
        // Clean unique labels
        var uniqueLabels: [String] = []
        for label in objectLabels {
            if !uniqueLabels.contains(label) && !label.isEmpty {
                uniqueLabels.append(label)
            }
        }
        
        let primary = uniqueLabels.first ?? "Wonder Item"
        let secondary = uniqueLabels.count > 1 ? uniqueLabels[1] : "Sparkle"
        let tertiary = uniqueLabels.count > 2 ? uniqueLabels[2] : "Star"
        
        let (storyTitle, storyNarrative) = makeNarrative(primary: primary, secondary: secondary, tertiary: tertiary)
        
        let tasks: [GeneratedTaskContent] = [
            GeneratedTaskContent(
                title: "\(primary) Discovery",
                storySegment: "Look closely at the \(primary.lowercased())! It has a special surprise for you.",
                taskDescription: "What kind of item is a \(primary.lowercased())?",
                taskType: .quizQuestion,
                difficulty: .easy,
                payload: .quiz(
                    options: quizOptions(for: primary),
                    correctAnswerIndex: 0
                )
            ),
            GeneratedTaskContent(
                title: "Counting \(secondary)s",
                storySegment: "Suddenly, magical \(secondary.lowercased())s started popping up everywhere!",
                taskDescription: "How many \(secondary.lowercased())s do you see?",
                taskType: .countObjects,
                difficulty: .easy,
                payload: .count(correctCount: 3, objectLabel: secondary)
            ),
            GeneratedTaskContent(
                title: "Tap the \(primary)",
                storySegment: "Quick! The \(primary.lowercased()) is bouncing around with joy!",
                taskDescription: "Tap all the stars to help the \(primary.lowercased())!",
                taskType: .tapObjects,
                difficulty: .easy,
                payload: .tap(targetCount: 4, objectLabel: primary)
            )
        ]
        
        return GeneratedStoryContent(
            title: storyTitle,
            story: storyNarrative,
            tasks: tasks
        )
    }
    
    /// Generates a customized story title and narrative based on the primary object category.
    private func makeNarrative(primary: String, secondary: String, tertiary: String) -> (title: String, narrative: String) {
        let p = primary.lowercased()
        let s = secondary.lowercased()
        let t = tertiary.lowercased()
        
        let title = "The Tale of the \(primary)"
        
        if p.contains("apple") || p.contains("fruit") || p.contains("food") || p.contains("banana") || p.contains("orange") {
            return (
                title,
                "One sunny morning, a shiny \(primary.lowercased()) woke up in a magic garden. Nearby, a curious \(s) noticed how colorful and bright it looked. Together with a friendly \(t), they set off on a delicious adventure!"
            )
        } else if p.contains("book") || p.contains("paper") || p.contains("notebook") {
            return (
                title,
                "Once upon a time, a magical \(primary.lowercased()) opened its pages to reveal secret maps. A brave \(s) followed the clues past the enchanted \(t). Every page led to brand new discoveries!"
            )
        } else if p.contains("dog") || p.contains("cat") || p.contains("bear") || p.contains("animal") || p.contains("pet") || p.contains("bird") {
            return (
                title,
                "A happy little \(primary.lowercased()) ran through the green meadow! It found a shiny \(s) lying under a tall tree. Along with a playful \(t), they played fun games all afternoon!"
            )
        } else if p.contains("car") || p.contains("vehicle") || p.contains("bus") || p.contains("truck") || p.contains("toy") {
            return (
                title,
                "Vroom vroom! A speedy little \(primary.lowercased()) zoomed down the magic highway! It beeped its horn at a friendly \(s) and raced past the \(t). What an exciting journey!"
            )
        } else if p.contains("flower") || p.contains("plant") || p.contains("tree") || p.contains("leaf") {
            return (
                title,
                "In a quiet magical forest, a vibrant \(primary.lowercased()) bloomed in the morning light. A little \(s) hovered nearby while the \(t) danced in the breeze!"
            )
        } else {
            return (
                title,
                "Once upon a time, an extraordinary \(primary.lowercased()) embarked on a grand quest. Along the way, it met a delightful \(s) and discovered a secret \(t). Together, they created a day full of magic!"
            )
        }
    }
    
    /// Returns plausible quiz options tailored for the detected object label.
    private func quizOptions(for label: String) -> [String] {
        let lower = label.lowercased()
        if lower.contains("apple") || lower.contains("fruit") || lower.contains("food") {
            return ["A Yummy Fruit 🍎", "A Flying Toy ✈️", "A Cold Ice Cube 🧊"]
        } else if lower.contains("book") || lower.contains("paper") {
            return ["A Story Book 📚", "A Cooking Pot 🍲", "A Pair of Shoes 👟"]
        } else if lower.contains("dog") || lower.contains("cat") || lower.contains("bear") || lower.contains("animal") {
            return ["A Cute Animal 🐶", "A Heavy Rock 🪨", "A Wooden Chair 🪑"]
        } else if lower.contains("car") || lower.contains("vehicle") || lower.contains("bus") {
            return ["A Fast Vehicle 🚗", "A Sweet Donut 🍩", "A Soft Pillow 🛋️"]
        } else if lower.contains("flower") || lower.contains("plant") || lower.contains("tree") {
            return ["A Pretty Plant 🌸", "A Metal Clock ⏰", "A Fast Train 🚆"]
        } else {
            return ["A Special Discovery ✨", "A Heavy Stone 🪨", "An Ocean Wave 🌊"]
        }
    }
}
