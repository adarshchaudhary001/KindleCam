import SwiftUI
import Combine

struct ShadowGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOptionId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var timeRemaining: Int = 25
    @State private var timerSubscription: AnyCancellable? = nil

    // Feedback states
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [ShadowQuestion] = [
        ShadowQuestion(
            promptText: "Match the apple to its shadow!",
            targetEmoji: "🍎",
            targetRotation: 0,
            shadowOptions: [
                ShadowOption(emoji: "🍌", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🍎", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: true),
                ShadowOption(emoji: "⭐️", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🚗", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false)
            ],
            hasTimer: false
        ),
        ShadowQuestion(
            promptText: "Match the ROTATED object shadow! ",
            targetEmoji: "🚗",
            targetRotation: 90,
            shadowOptions: [
                ShadowOption(emoji: "🚗", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🚗", rotationDegrees: 90, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: true),
                ShadowOption(emoji: "🚚", rotationDegrees: 90, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🚗", rotationDegrees: 180, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false)
            ],
            hasTimer: false
        ),
        ShadowQuestion(
            promptText: "Match the UPSIDE-DOWN shadow! ",
            targetEmoji: "🐱",
            targetRotation: 0,
            shadowOptions: [
                ShadowOption(emoji: "🐱", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🐶", rotationDegrees: 0, isUpsideDown: true, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🐱", rotationDegrees: 0, isUpsideDown: true, isOddDistorted: false, isTargetCorrect: true),
                ShadowOption(emoji: "🐰", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false)
            ],
            hasTimer: false
        ),
        ShadowQuestion(
            promptText: "Find the ODD shadow! ",
            targetEmoji: "⭐️",
            targetRotation: 0,
            shadowOptions: [
                ShadowOption(emoji: "⭐️", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "⭐️", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🌙", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: true, isTargetCorrect: true),
                ShadowOption(emoji: "⭐️", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false)
            ],
            hasTimer: false
        ),
        ShadowQuestion(
            promptText: "Match the shadow BEFORE TIME RUNS OUT! ",
            targetEmoji: "🚀",
            targetRotation: 0,
            shadowOptions: [
                ShadowOption(emoji: "🛸", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "✈️", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false),
                ShadowOption(emoji: "🚀", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: true),
                ShadowOption(emoji: "🚁", rotationDegrees: 0, isUpsideDown: false, isOddDistorted: false, isTargetCorrect: false)
            ],
            hasTimer: true
        )
    ]

    var currentQuestion: ShadowQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Navigation & Progress Header
                ProgressBarView(
                    categoryTitle: "Match Shadow ",
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    promptText: currentQuestion.promptText,
                    onBackTapped: {
                        SoundManager.shared.stopAllAudio()
                        stopTimer()
                        onBackToHome()
                    },
                    onSpeakTapped: {
                        SoundManager.shared.speak(currentQuestion.promptText)
                    }
                )

                // Optional Countdown Timer Badge for question 5
                if currentQuestion.hasTimer {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(timeRemaining < 8 ? .red : .purple)
                        Text("Time Remaining: \(timeRemaining)s")
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(timeRemaining < 8 ? .red : .purple)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.9)))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                }

                Spacer()

                // Center Object Display Card
                VStack(spacing: 16) {
                    Text("Original Object:")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 150, height: 150)
                            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)

                        Text(currentQuestion.targetEmoji)
                            .font(.system(size: 85))
                            .rotationEffect(.degrees(currentQuestion.targetRotation))
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
                )

                Spacer()

                // Shadow Choices Grid below
                VStack(spacing: 12) {
                    Text("Tap the matching shadow:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.indigo)

                    HStack(spacing: 24) {
                        ForEach(currentQuestion.shadowOptions) { option in
                            Button(action: {
                                handleOptionTap(option)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(selectedOptionId == option.id ? (option.isTargetCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                        .frame(width: 120, height: 120)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(selectedOptionId == option.id ? (option.isTargetCorrect ? Color.green : Color.red) : Color.indigo.opacity(0.3), lineWidth: selectedOptionId == option.id ? 4 : 2)
                                        )

                                    // Silhouette Shadow (Black/Dark tint rendering)
                                    Text(option.emoji)
                                        .font(.system(size: 70))
                                        .colorMultiply(.black)
                                        .opacity(0.85)
                                        .rotationEffect(.degrees(option.rotationDegrees))
                                        .scaleEffect(y: option.isUpsideDown ? -1.0 : 1.0)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.bottom, 36)
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
            stopTimer()
        }
    }

    private func loadQuestion(index: Int) {
        currentQuestionIndex = index
        selectedOptionId = nil
        isCorrect = false
        showWrongBanner = false
        stopTimer()

        let q = questions[index]
        SoundManager.shared.speak(q.promptText)

        if q.hasTimer {
            timeRemaining = 25
            startTimer()
        }
    }

    private func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    stopTimer()
                    triggerWrongFeedback(message: "Time's up! Let's try matching again!")
                }
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func handleOptionTap(_ option: ShadowOption) {
        selectedOptionId = option.id

        if option.isTargetCorrect {
            stopTimer()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCorrect = true
            }
            SoundManager.shared.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Oops! Look closely at the shape and rotation!")
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
        progressManager.markQuestionCompleted(category: .matchShadow, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .matchShadow)
            onFinishCategory()
        }
    }
}
