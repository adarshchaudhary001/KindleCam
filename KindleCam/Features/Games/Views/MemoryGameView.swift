import SwiftUI

struct MemoryGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var isMemorizing: Bool = true
    @State private var countdownRemaining: Int = 4
    @State private var countdownTimer: Timer? = nil

    // State for Q1 & Q4 sequential order tapping
    @State private var tappedItems: [UUID] = []

    // State for feedback & option selection
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [MemoryQuestion] = [
        // Q1: Remember these 4 objects
        MemoryQuestion(
            type: .rememberAndTap,
            promptText: "Remember these 4 objects! ",
            initialItems: [
                MemoryItem(label: "Apple", emoji: "🍎", color: .red, isTarget: true),
                MemoryItem(label: "Cat", emoji: "🐱", color: .orange, isTarget: true),
                MemoryItem(label: "Star", emoji: "⭐️", color: .yellow, isTarget: true),
                MemoryItem(label: "Rocket", emoji: "🚀", color: .purple, isTarget: true)
            ],
            questionItems: [],
            choices: [
                MemoryItem(label: "Cat", emoji: "🐱", color: .orange, isTarget: true),
                MemoryItem(label: "Banana", emoji: "🍌", color: .yellow, isTarget: false),
                MemoryItem(label: "Apple", emoji: "🍎", color: .red, isTarget: true),
                MemoryItem(label: "Star", emoji: "⭐️", color: .yellow, isTarget: true),
                MemoryItem(label: "Dog", emoji: "🐶", color: .brown, isTarget: false),
                MemoryItem(label: "Rocket", emoji: "🚀", color: .purple, isTarget: true)
            ],
            previewDuration: 4.0
        ),
        // Q2: Which one disappeared?
        MemoryQuestion(
            type: .identifyMissing,
            promptText: "Which object disappeared?",
            initialItems: [
                MemoryItem(label: "Car", emoji: "🚗", color: .red, isTarget: false),
                MemoryItem(label: "Balloon", emoji: "🎈", color: .pink, isTarget: true), // The missing one
                MemoryItem(label: "Sun", emoji: "☀️", color: .yellow, isTarget: false),
                MemoryItem(label: "Panda", emoji: "🐼", color: .gray, isTarget: false)
            ],
            questionItems: [
                MemoryItem(label: "Car", emoji: "🚗", color: .red, isTarget: false),
                MemoryItem(label: "Sun", emoji: "☀️", color: .yellow, isTarget: false),
                MemoryItem(label: "Panda", emoji: "🐼", color: .gray, isTarget: false)
            ],
            choices: [
                MemoryItem(label: "Frog", emoji: "🐸", color: .green, isTarget: false),
                MemoryItem(label: "Balloon", emoji: "🎈", color: .pink, isTarget: true),
                MemoryItem(label: "Car", emoji: "🚗", color: .red, isTarget: false),
                MemoryItem(label: "Cake", emoji: "🎂", color: .purple, isTarget: false)
            ],
            previewDuration: 3.5
        ),
        // Q3: Which object moved?
        MemoryQuestion(
            type: .identifyMoved,
            promptText: "Which object moved? ",
            initialItems: [
                MemoryItem(label: "Fish", emoji: "🐟", color: .cyan, isTarget: false),
                MemoryItem(label: "Rabbit", emoji: "🐰", color: .pink, isTarget: false),
                MemoryItem(label: "Duck", emoji: "🦆", color: .green, isTarget: true), // Moved to end
                MemoryItem(label: "Flower", emoji: "🌺", color: .purple, isTarget: false)
            ],
            questionItems: [
                MemoryItem(label: "Fish", emoji: "🐟", color: .cyan, isTarget: false),
                MemoryItem(label: "Rabbit", emoji: "🐰", color: .pink, isTarget: false),
                MemoryItem(label: "Flower", emoji: "🌺", color: .purple, isTarget: false),
                MemoryItem(label: "Duck", emoji: "🦆", color: .green, isTarget: true)
            ],
            choices: [
                MemoryItem(label: "Fish", emoji: "🐟", color: .cyan, isTarget: false),
                MemoryItem(label: "Duck", emoji: "🦆", color: .green, isTarget: true),
                MemoryItem(label: "Rabbit", emoji: "🐰", color: .pink, isTarget: false),
                MemoryItem(label: "Flower", emoji: "🌺", color: .purple, isTarget: false)
            ],
            previewDuration: 3.5
        ),
        // Q4: Tap them in the same order!
        MemoryQuestion(
            type: .repeatOrder,
            promptText: "Tap them in the same order! ",
            initialItems: [
                MemoryItem(label: "Strawberry", emoji: "🍓", color: .red, isTarget: true),
                MemoryItem(label: "Crown", emoji: "👑", color: .yellow, isTarget: true),
                MemoryItem(label: "Dolphin", emoji: "🐬", color: .blue, isTarget: true)
            ],
            questionItems: [],
            choices: [
                MemoryItem(label: "Crown", emoji: "👑", color: .yellow, isTarget: false),
                MemoryItem(label: "Strawberry", emoji: "🍓", color: .red, isTarget: false),
                MemoryItem(label: "Dolphin", emoji: "🐬", color: .blue, isTarget: false)
            ],
            previewDuration: 3.0
        ),
        // Q5: Which object is new?
        MemoryQuestion(
            type: .identifyNew,
            promptText: "Which object is NEW? ",
            initialItems: [
                MemoryItem(label: "Dog", emoji: "🐶", color: .orange, isTarget: false),
                MemoryItem(label: "Cat", emoji: "🐱", color: .yellow, isTarget: false),
                MemoryItem(label: "Bear", emoji: "🐻", color: .brown, isTarget: false)
            ],
            questionItems: [
                MemoryItem(label: "Dog", emoji: "🐶", color: .orange, isTarget: false),
                MemoryItem(label: "Cat", emoji: "🐱", color: .yellow, isTarget: false),
                MemoryItem(label: "Fox", emoji: "🦊", color: .red, isTarget: true), // New item
                MemoryItem(label: "Bear", emoji: "🐻", color: .brown, isTarget: false)
            ],
            choices: [
                MemoryItem(label: "Dog", emoji: "🐶", color: .orange, isTarget: false),
                MemoryItem(label: "Fox", emoji: "🦊", color: .red, isTarget: true),
                MemoryItem(label: "Bear", emoji: "🐻", color: .brown, isTarget: false),
                MemoryItem(label: "Cat", emoji: "🐱", color: .yellow, isTarget: false)
            ],
            previewDuration: 3.5
        )
    ]

    var currentQuestion: MemoryQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Progress Header
                ProgressBarView(
                    categoryTitle: "Memory Game ",
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    promptText: isMemorizing ? currentQuestion.promptText : (
                        currentQuestion.type == .rememberAndTap ? "Tap the 4 objects you saw!" : currentQuestion.promptText
                    ),
                    onBackTapped: {
                        SoundManager.shared.stopAllAudio()
                        stopTimer()
                        onBackToHome()
                    },
                    onSpeakTapped: {
                        SoundManager.shared.speak(isMemorizing ? currentQuestion.promptText : "Tap your answer!")
                    }
                )

                Spacer()

                // Question Body View
                if isMemorizing {
                    VStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Memorize! Hiding in \(countdownRemaining)s...")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

                        // Preview Grid of Initial Items
                        HStack(spacing: 24) {
                            ForEach(currentQuestion.initialItems) { item in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(item.color.opacity(0.15))
                                            .frame(width: 120, height: 120)
                                            .overlay(Circle().stroke(item.color, lineWidth: 3))
                                        Text(item.emoji)
                                            .font(.system(size: 70))
                                    }
                                    Text(item.label)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Question Phase View
                    VStack(spacing: 24) {
                        if currentQuestion.type == .identifyMissing || currentQuestion.type == .identifyMoved || currentQuestion.type == .identifyNew {
                            Text("Look closely:")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)

                            HStack(spacing: 20) {
                                ForEach(currentQuestion.questionItems) { item in
                                    ZStack {
                                        Circle()
                                            .fill(item.color.opacity(0.15))
                                            .frame(width: 100, height: 100)
                                            .overlay(Circle().stroke(item.color, lineWidth: 3))

                                        Text(item.emoji)
                                            .font(.system(size: 55))
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.9))
                            )
                        }

                        Text("Tap your answer:")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.blue)

                        // Choices Grid
                        let cols = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: cols, spacing: 20) {
                            ForEach(currentQuestion.choices) { item in
                                Button(action: {
                                    handleChoiceTap(item)
                                }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(item.color.opacity(0.2))
                                                .frame(width: 70, height: 70)
                                            Text(item.emoji)
                                                .font(.system(size: 45))
                                        }

                                        Text(item.label)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if tappedItems.contains(item.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedItemId == item.id ? (item.isTarget ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedItemId == item.id ? (item.isTarget ? Color.green : Color.red) : Color.blue.opacity(0.3), lineWidth: 3)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .frame(maxWidth: 700)
                    }
                    .transition(.opacity)
                }

                Spacer()
            }

            // Wrong Banner
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
                    .background(Capsule().fill(Color.blue))
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
            stopTimer()
        }
    }

    private func loadQuestion(index: Int) {
        currentQuestionIndex = index
        selectedItemId = nil
        tappedItems = []
        isCorrect = false
        showWrongBanner = false
        isMemorizing = true
        countdownRemaining = Int(questions[index].previewDuration)

        SoundManager.shared.speak(questions[index].promptText)

        startCountdown(duration: questions[index].previewDuration)
    }

    private func startCountdown(duration: Double) {
        stopTimer()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdownRemaining > 1 {
                countdownRemaining -= 1
            } else {
                stopTimer()
                withAnimation(.easeInOut(duration: 0.4)) {
                    isMemorizing = false
                }
                if currentQuestion.type == .rememberAndTap {
                    SoundManager.shared.speak("Tap the 4 objects you saw!")
                } else if currentQuestion.type == .repeatOrder {
                    SoundManager.shared.speak("Tap them in the same order!")
                } else {
                    SoundManager.shared.speak(currentQuestion.promptText)
                }
            }
        }
    }

    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func handleChoiceTap(_ item: MemoryItem) {
        selectedItemId = item.id

        if currentQuestion.type == .rememberAndTap {
            if item.isTarget {
                if !tappedItems.contains(item.id) {
                    tappedItems.append(item.id)
                }
                SoundManager.shared.playCorrectFeedback()

                // Check if all 4 targets tapped
                let targetCount = currentQuestion.choices.filter { $0.isTarget }.count
                if tappedItems.count >= targetCount {
                    withAnimation {
                        isCorrect = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        advanceQuestion()
                    }
                }
            } else {
                triggerWrongFeedback(message: "Oops! That item wasn't in the original group!")
            }
        } else if currentQuestion.type == .repeatOrder {
            let nextIndex = tappedItems.count
            let correctSequence = currentQuestion.initialItems

            if nextIndex < correctSequence.count && correctSequence[nextIndex].emoji == item.emoji {
                tappedItems.append(item.id)
                SoundManager.shared.playCorrectFeedback()

                if tappedItems.count == correctSequence.count {
                    withAnimation {
                        isCorrect = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        advanceQuestion()
                    }
                }
            } else {
                triggerWrongFeedback(message: "Not that order! Let me try again!")
                tappedItems = []
            }
        } else {
            // Multiple choice single selection (missing, moved, new)
            if item.isTarget {
                withAnimation {
                    isCorrect = true
                }
                SoundManager.shared.playCorrectFeedback()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    advanceQuestion()
                }
            } else {
                triggerWrongFeedback(message: "Oops! Look closely and try again!")
            }
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
        progressManager.markQuestionCompleted(category: .memoryGame, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .memoryGame)
            onFinishCategory()
        }
    }
}
