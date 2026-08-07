import SwiftUI

struct ShapeGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [ShapeQuestion] = [
        // Q1: Find the Red Circle
        ShapeQuestion(
            promptText: "Find the RED CIRCLE! ",
            items: [
                ShapeItem(label: "Blue Square", emoji: "🟦", shapeName: "Square", colorName: "Blue", sideCount: 4, color: .blue, isCorrectTarget: false),
                ShapeItem(label: "Red Circle", emoji: "🔴", shapeName: "Circle", colorName: "Red", sideCount: 0, color: .red, isCorrectTarget: true),
                ShapeItem(label: "Yellow Triangle", emoji: "🔺", shapeName: "Triangle", colorName: "Yellow", sideCount: 3, color: .yellow, isCorrectTarget: false),
                ShapeItem(label: "Green Star", emoji: "⭐️", shapeName: "Star", colorName: "Green", sideCount: 5, color: .green, isCorrectTarget: false)
            ]
        ),
        // Q2: Match the Triangle
        ShapeQuestion(
            promptText: "Match the TRIANGLE! ",
            items: [
                ShapeItem(label: "Orange Diamond", emoji: "🔸", shapeName: "Diamond", colorName: "Orange", sideCount: 4, color: .orange, isCorrectTarget: false),
                ShapeItem(label: "Purple Heart", emoji: "💜", shapeName: "Heart", colorName: "Purple", sideCount: 0, color: .purple, isCorrectTarget: false),
                ShapeItem(label: "Red Triangle", emoji: "🔺", shapeName: "Triangle", colorName: "Red", sideCount: 3, color: .red, isCorrectTarget: true),
                ShapeItem(label: "Blue Circle", emoji: "🔵", shapeName: "Circle", colorName: "Blue", sideCount: 0, color: .blue, isCorrectTarget: false)
            ]
        ),
        // Q3: Which object has 4 sides?
        ShapeQuestion(
            promptText: "Which object has 4 SIDES? ",
            items: [
                ShapeItem(label: "Green Circle", emoji: "🟢", shapeName: "Circle", colorName: "Green", sideCount: 0, color: .green, isCorrectTarget: false),
                ShapeItem(label: "Orange Square", emoji: "🟧", shapeName: "Square", colorName: "Orange", sideCount: 4, color: .orange, isCorrectTarget: true),
                ShapeItem(label: "Pink Triangle", emoji: "🔺", shapeName: "Triangle", colorName: "Pink", sideCount: 3, color: .pink, isCorrectTarget: false),
                ShapeItem(label: "Yellow Star", emoji: "🌟", shapeName: "Star", colorName: "Yellow", sideCount: 5, color: .yellow, isCorrectTarget: false)
            ]
        ),
        // Q4: Find the green item
        ShapeQuestion(
            promptText: "Find the GREEN object! ",
            items: [
                ShapeItem(label: "Red Apple", emoji: "🍎", shapeName: "Apple", colorName: "Red", sideCount: 0, color: .red, isCorrectTarget: false),
                ShapeItem(label: "Yellow Banana", emoji: "🍌", shapeName: "Banana", colorName: "Yellow", sideCount: 0, color: .yellow, isCorrectTarget: false),
                ShapeItem(label: "Green Leaf", emoji: "🍃", shapeName: "Leaf", colorName: "Green", sideCount: 0, color: .green, isCorrectTarget: true),
                ShapeItem(label: "Purple Grape", emoji: "🍇", shapeName: "Grape", colorName: "Purple", sideCount: 0, color: .purple, isCorrectTarget: false)
            ]
        ),
        // Q5: Complete the pattern
        ShapeQuestion(
            promptText: "Complete the pattern: 🔴 🔵 🔴 ...❓",
            items: [
                ShapeItem(label: "Red Circle", emoji: "🔴", shapeName: "Circle", colorName: "Red", sideCount: 0, color: .red, isCorrectTarget: false),
                ShapeItem(label: "Blue Circle", emoji: "🔵", shapeName: "Circle", colorName: "Blue", sideCount: 0, color: .blue, isCorrectTarget: true),
                ShapeItem(label: "Yellow Star", emoji: "⭐️", shapeName: "Star", colorName: "Yellow", sideCount: 5, color: .yellow, isCorrectTarget: false),
                ShapeItem(label: "Green Square", emoji: "🟩", shapeName: "Square", colorName: "Green", sideCount: 4, color: .green, isCorrectTarget: false)
            ]
        )
    ]

    var currentQuestion: ShapeQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header
                ProgressBarView(
                    categoryTitle: "Shape Explorer ",
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    promptText: currentQuestion.promptText,
                    onBackTapped: {
                        SoundManager.shared.stopAllAudio()
                        onBackToHome()
                    },
                    onSpeakTapped: {
                        SoundManager.shared.speak(currentQuestion.promptText)
                    }
                )

                Spacer()

                Text("Tap the matching shape or color:")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.purple)

                // 2x2 Options Grid
                let cols = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: cols, spacing: 24) {
                    ForEach(currentQuestion.items) { item in
                        Button(action: {
                            handleItemTap(item)
                        }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green.opacity(0.25) : Color.red.opacity(0.25)) : Color.white)
                                        .frame(width: 140, height: 140)
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green : Color.red) : item.color.opacity(0.4), lineWidth: selectedItemId == item.id ? 5 : 3)
                                        )

                                    Text(item.emoji)
                                        .font(.system(size: 80))
                                }

                                Text(item.label)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 48)
                .frame(maxWidth: 800)

                Spacer()
            }

            // Wrong Toast
            if showWrongBanner {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        Text(wrongMessage)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.purple))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            loadQuestion(index: currentQuestionIndex)
        }
        .onDisappear {
            SoundManager.shared.stopAllAudio()
        }
    }

    private func loadQuestion(index: Int) {
        currentQuestionIndex = index
        selectedItemId = nil
        isCorrect = false
        showWrongBanner = false
        SoundManager.shared.speak(questions[index].promptText)
    }

    private func handleItemTap(_ item: ShapeItem) {
        selectedItemId = item.id

        if item.isCorrectTarget {
            withAnimation(.spring()) {
                isCorrect = true
            }
            SoundManager.shared.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Not that one! Look closely at the shape or color!")
        }
    }

    private func triggerWrongFeedback(message: String) {
        wrongMessage = message
        SoundManager.shared.playWrongFeedback()

        withAnimation {
            showWrongBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation {
                showWrongBanner = false
            }
        }
    }

    private func advanceQuestion() {
        progressManager.markQuestionCompleted(category: .shapeExplorer, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .shapeExplorer)
            onFinishCategory()
        }
    }
}
