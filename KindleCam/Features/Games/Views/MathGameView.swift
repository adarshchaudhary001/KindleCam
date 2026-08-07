import SwiftUI

struct MathGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [MathQuestion] = [
        // Q1: How many total stars? ⭐️ + ⭐️ = ❓
        MathQuestion(
            promptText: "How many total stars?",
            visualExpression: "⭐️ + ⭐️ =",
            items: [
                MathItem(label: "1 Star", valueText: "1", emoji: "⭐️", count: 1, isCorrectTarget: false),
                MathItem(label: "2 Stars", valueText: "2", emoji: "⭐️⭐️", count: 2, isCorrectTarget: true),
                MathItem(label: "3 Stars", valueText: "3", emoji: "⭐️⭐️⭐️", count: 3, isCorrectTarget: false),
                MathItem(label: "4 Stars", valueText: "4", emoji: "⭐️⭐️⭐️⭐️", count: 4, isCorrectTarget: false)
            ]
        ),
        // Q2: Add the apples! 🍎🍎 + 🍎 = ❓
        MathQuestion(
            promptText: "Add the apples!",
            visualExpression: "🍎🍎 + 🍎 =",
            items: [
                MathItem(label: "2 Apples", valueText: "2", emoji: "🍎🍎", count: 2, isCorrectTarget: false),
                MathItem(label: "3 Apples", valueText: "3", emoji: "🍎🍎🍎", count: 3, isCorrectTarget: true),
                MathItem(label: "4 Apples", valueText: "4", emoji: "🍎🍎🍎🍎", count: 4, isCorrectTarget: false),
                MathItem(label: "5 Apples", valueText: "5", emoji: "🍎🍎🍎🍎🍎", count: 5, isCorrectTarget: false)
            ]
        ),
        // Q3: Which group has MORE balloons? 🎈🎈🎈 vs 🎈
        MathQuestion(
            promptText: "Which group has MORE balloons? ",
            visualExpression: "Group A vs Group B",
            items: [
                MathItem(label: "3 Balloons", valueText: "3", emoji: "🎈🎈🎈", count: 3, isCorrectTarget: true),
                MathItem(label: "1 Balloon", valueText: "1", emoji: "🎈", count: 1, isCorrectTarget: false)
            ]
        ),
        // Q4: Take away 1 cookie! 🍪🍪🍪 - 🍪 = ❓
        MathQuestion(
            promptText: "Take away 1 cookie!",
            visualExpression: "🍪🍪🍪 - 🍪 =",
            items: [
                MathItem(label: "1 Cookie", valueText: "1", emoji: "🍪", count: 1, isCorrectTarget: false),
                MathItem(label: "2 Cookies", valueText: "2", emoji: "🍪🍪", count: 2, isCorrectTarget: true),
                MathItem(label: "3 Cookies", valueText: "3", emoji: "🍪🍪🍪", count: 3, isCorrectTarget: false),
                MathItem(label: "4 Cookies", valueText: "4", emoji: "🍪🍪🍪🍪", count: 4, isCorrectTarget: false)
            ]
        ),
        // Q5: Match number 5 to 5 cute puppies!
        MathQuestion(
            promptText: "Tap the group with 5 puppies! ",
            visualExpression: "Find 5️⃣ Puppies:",
            items: [
                MathItem(label: "3 Puppies", valueText: "3", emoji: "🐶🐶🐶", count: 3, isCorrectTarget: false),
                MathItem(label: "5 Puppies", valueText: "5", emoji: "🐶🐶🐶🐶🐶", count: 5, isCorrectTarget: true),
                MathItem(label: "2 Puppies", valueText: "2", emoji: "🐶🐶", count: 2, isCorrectTarget: false),
                MathItem(label: "4 Puppies", valueText: "4", emoji: "🐶🐶🐶🐶", count: 4, isCorrectTarget: false)
            ]
        )
    ]

    var currentQuestion: MathQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header Bar
                ProgressBarView(
                    categoryTitle: "Math & Counting ",
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

                // Visual Equation Banner Card
                VStack(spacing: 8) {
                    Text(currentQuestion.visualExpression)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.indigo)

                    Text("Tap the correct answer:")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )

                Spacer()

                // Choices Layout
                if currentQuestion.items.count == 2 {
                    // Side by Side comparison for Q3
                    HStack(spacing: 48) {
                        ForEach(currentQuestion.items) { item in
                            Button(action: {
                                handleItemTap(item)
                            }) {
                                VStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                            .frame(width: 240, height: 180)
                                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 28)
                                                    .stroke(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green : Color.red) : Color.indigo.opacity(0.3), lineWidth: selectedItemId == item.id ? 4 : 2)
                                            )

                                        Text(item.emoji)
                                            .font(.system(size: 55))
                                    }

                                    Text(item.label)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    // 2x2 Grid for 4-choice math questions
                    let cols = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: cols, spacing: 20) {
                        ForEach(currentQuestion.items) { item in
                            Button(action: {
                                handleItemTap(item)
                            }) {
                                HStack(spacing: 20) {
                                    Text(item.valueText)
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundColor(.indigo)
                                        .frame(width: 70, height: 70)
                                        .background(Circle().fill(Color.indigo.opacity(0.12)))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.emoji)
                                            .font(.system(size: 32))
                                            .lineLimit(1)

                                        Text(item.label)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green : Color.red) : Color.indigo.opacity(0.3), lineWidth: selectedItemId == item.id ? 4 : 2)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 48)
                    .frame(maxWidth: 800)
                }

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
                    .background(Capsule().fill(Color.indigo))
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

    private func handleItemTap(_ item: MathItem) {
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
            triggerWrongFeedback(message: "Not quite! Count the objects and try again!")
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
        progressManager.markQuestionCompleted(category: .mathFun, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .mathFun)
            onFinishCategory()
        }
    }
}
