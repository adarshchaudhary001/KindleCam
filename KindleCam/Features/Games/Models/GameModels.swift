import SwiftUI
import Combine

// MARK: - Game Category
enum GameCategory: String, CaseIterable, Identifiable {
    case counting = "counting"
    case sequence = "sequence"
    case wordCompletion = "wordCompletion"
    case matchShadow = "matchShadow"
    case findOddOne = "findOddOne"
    case memoryGame = "memoryGame"
    case sizeComparison = "sizeComparison"
    case shapeExplorer = "shapeExplorer"
    case animalWorld = "animalWorld"
    case mathFun = "mathFun"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .counting: return "Count Objects"
        case .sequence: return "Sequence Game"
        case .wordCompletion: return "Complete Word"
        case .matchShadow: return "Match Shadow"
        case .findOddOne: return "Find Odd One"
        case .memoryGame: return "Memory Game"
        case .sizeComparison: return "Bigger or Smaller"
        case .shapeExplorer: return "Shape Explorer"
        case .animalWorld: return "Animal World"
        case .mathFun: return "Math & Counting"
        }
    }

    var subtitle: String {
        switch self {
        case .counting: return "Learn to count items!"
        case .sequence: return "Order items logically!"
        case .wordCompletion: return "Spell & learn words!"
        case .matchShadow: return "Recognize shapes & shadows!"
        case .findOddOne: return "Logical thinking & patterns!"
        case .memoryGame: return "Train short-term memory!"
        case .sizeComparison: return "Compare sizes & height!"
        case .shapeExplorer: return "Learn shapes & colors!"
        case .animalWorld: return "Sounds, habitats & food!"
        case .mathFun: return "Addition, subtraction & more!"
        }
    }

    var icon: String {
        switch self {
        case .counting: return "number.circle.fill"
        case .sequence: return "arrow.triangle.2.circlepath"
        case .wordCompletion: return "character.book.closed.fill"
        case .matchShadow: return "moon.stars.fill"
        case .findOddOne: return "magnifyingglass.circle.fill"
        case .memoryGame: return "brain.head.profile"
        case .sizeComparison: return "ruler.fill"
        case .shapeExplorer: return "square.on.circle.fill"
        case .animalWorld: return "pawprint.fill"
        case .mathFun: return "plus.forwardslash.minus"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .counting: return [Color.orange, Color.red]
        case .sequence: return [Color.purple, Color.blue]
        case .wordCompletion: return [Color.green, Color.mint]
        case .matchShadow: return [Color.indigo, Color.purple]
        case .findOddOne: return [Color.pink, Color.orange]
        case .memoryGame: return [Color.blue, Color.cyan]
        case .sizeComparison: return [Color.teal, Color.green]
        case .shapeExplorer: return [Color.purple, Color.pink]
        case .animalWorld: return [Color.orange, Color.yellow]
        case .mathFun: return [Color.indigo, Color.blue]
        }
    }

    var totalQuestions: Int {
        return 5
    }
}

// MARK: - Counting Game Data Models
struct PlacedObject: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
    let scale: CGFloat
    let isOnTree: Bool
    let hasStar: Bool
    let isTarget: Bool
    var normalizedPosition: CGPoint
    var isCounted: Bool = false
}

struct CountQuestion: Identifiable {
    let id = UUID()
    let title: String
    let promptText: String
    let targetCriteriaDescription: String
    let objects: [PlacedObject]
}

// MARK: - Sequence Game Data Models
enum SequenceType {
    case leftToRight
    case smallestToBiggest
    case rainbowColors
    case numbers1To5
    case lifeCycle
}

struct SequenceItem: Identifiable, Equatable {
    let id = UUID()
    let targetOrder: Int
    let label: String
    let emoji: String
    let color: Color
    let scale: CGFloat
    let normalizedPosition: CGPoint
    var isCompleted: Bool = false
}

struct SequenceQuestion: Identifiable {
    let id = UUID()
    let type: SequenceType
    let title: String
    let promptText: String
    let items: [SequenceItem]
}

// MARK: - Complete the Word Data Models
struct WordQuestion: Identifiable {
    let id = UUID()
    let fullWord: String
    let displayedWord: String
    let missingLetterIndex: Int
    let missingLetter: Character
    let clueEmoji: String
    let letterChoices: [Character]
}

// MARK: - Match the Shadow Data Models
struct ShadowOption: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let rotationDegrees: Double
    let isUpsideDown: Bool
    let isOddDistorted: Bool
    let isTargetCorrect: Bool
}

struct ShadowQuestion: Identifiable {
    let id = UUID()
    let promptText: String
    let targetEmoji: String
    let targetRotation: Double
    let shadowOptions: [ShadowOption]
    let hasTimer: Bool
}

// MARK: - Find the Odd One Data Models
struct OddOneItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let emoji: String
    let color: Color
    let scaleX: CGFloat // -1 for flipped horizontally
    let isOddTarget: Bool
}

struct OddOneQuestion: Identifiable {
    let id = UUID()
    let promptText: String
    let items: [OddOneItem]
}

// MARK: - Memory Game Data Models
enum MemoryQuestionType {
    case rememberAndTap    // Q1: Remember 4 objects, then tap all 4
    case identifyMissing   // Q2: Which one disappeared?
    case identifyMoved     // Q3: Which object moved?
    case repeatOrder       // Q4: Tap them in the same order
    case identifyNew       // Q5: Which object is new?
}

struct MemoryItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let emoji: String
    let color: Color
    let isTarget: Bool
}

struct MemoryQuestion: Identifiable {
    let id = UUID()
    let type: MemoryQuestionType
    let promptText: String
    let initialItems: [MemoryItem]    // Items shown in memory preview phase
    let questionItems: [MemoryItem]   // Items shown during questioning phase
    let choices: [MemoryItem]         // Multiple choice options if applicable
    let previewDuration: Double       // Seconds to memorize (e.g. 4.0)
}

// MARK: - Size Comparison Data Models
enum SizeQuestionType {
    case tapBiggest        // Q1: Tap the biggest apple
    case tapSmallest       // Q2: Tap the smallest apple
    case arrangeSmallToBig // Q3: Arrange from small to big
    case compareTaller     // Q4: Which one is taller?
    case compareShorter    // Q5: Which one is shorter?
}

struct SizeItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let emoji: String
    let relativeSize: CGFloat // scale multiplier (e.g. 0.6, 1.0, 1.5)
    let heightRatio: CGFloat  // height ratio (e.g. 1.0 vs 2.2 for giraffe)
    let isTarget: Bool
    let correctOrder: Int     // for ordering questions
}

struct SizeQuestion: Identifiable {
    let id = UUID()
    let type: SizeQuestionType
    let promptText: String
    let items: [SizeItem]
}

// MARK: - Shape Explorer Data Models
struct ShapeItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let emoji: String
    let shapeName: String
    let colorName: String
    let sideCount: Int
    let color: Color
    let isCorrectTarget: Bool
}

struct ShapeQuestion: Identifiable {
    let id = UUID()
    let promptText: String
    let items: [ShapeItem]
}

// MARK: - Animal World Data Models
struct AnimalItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let emoji: String
    let soundText: String
    let habitat: String
    let isCorrectTarget: Bool
}

struct AnimalQuestion: Identifiable {
    let id = UUID()
    let promptText: String
    let items: [AnimalItem]
}

// MARK: - Math & Counting Data Models
struct MathItem: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let valueText: String
    let emoji: String
    let count: Int
    let isCorrectTarget: Bool
}

struct MathQuestion: Identifiable {
    let id = UUID()
    let promptText: String
    let visualExpression: String // e.g. "⭐️ + ⭐️ = ❓" or "🍎🍎 + 🍎 = ❓"
    let items: [MathItem]
}

// MARK: - Overall Game Progress Tracker
class GameProgressManager: ObservableObject {
    @Published var completedQuestions: [GameCategory: Int] = [
        .counting: 0,
        .sequence: 0,
        .wordCompletion: 0,
        .matchShadow: 0,
        .findOddOne: 0,
        .memoryGame: 0,
        .sizeComparison: 0,
        .shapeExplorer: 0,
        .animalWorld: 0,
        .mathFun: 0
    ]

    @Published var starsEarned: [GameCategory: Int] = [
        .counting: 0,
        .sequence: 0,
        .wordCompletion: 0,
        .matchShadow: 0,
        .findOddOne: 0,
        .memoryGame: 0,
        .sizeComparison: 0,
        .shapeExplorer: 0,
        .animalWorld: 0,
        .mathFun: 0
    ]

    func markQuestionCompleted(category: GameCategory, questionIndex: Int) {
        let current = completedQuestions[category] ?? 0
        if questionIndex + 1 > current {
            completedQuestions[category] = questionIndex + 1
        }
    }

    func finishCategory(category: GameCategory) {
        completedQuestions[category] = category.totalQuestions
        starsEarned[category] = 3
    }

    func resetCategory(category: GameCategory) {
        completedQuestions[category] = 0
        starsEarned[category] = 0
    }
}
