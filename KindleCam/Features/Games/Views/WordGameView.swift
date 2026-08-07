import SwiftUI

struct WordGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedLetter: Character? = nil
    @State private var isAnswerCorrect: Bool = false

    // Feedback states
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [WordQuestion] = [
        WordQuestion(
            fullWord: "APPLE",
            displayedWord: "A _ P L E",
            missingLetterIndex: 1,
            missingLetter: "P",
            clueEmoji: "🍎",
            letterChoices: ["P", "B", "M", "T"]
        ),
        WordQuestion(
            fullWord: "CUP",
            displayedWord: "C _ P",
            missingLetterIndex: 1,
            missingLetter: "U",
            clueEmoji: "☕",
            letterChoices: ["A", "U", "O", "E"]
        ),
        WordQuestion(
            fullWord: "BALL",
            displayedWord: "B A _ L",
            missingLetterIndex: 2,
            missingLetter: "L",
            clueEmoji: "⚽",
            letterChoices: ["R", "L", "K", "D"]
        ),
        WordQuestion(
            fullWord: "CARROT",
            displayedWord: "C A _ R O T",
            missingLetterIndex: 2,
            missingLetter: "R",
            clueEmoji: "🥕",
            letterChoices: ["W", "S", "R", "N"]
        ),
        WordQuestion(
            fullWord: "SUN",
            displayedWord: "S U _",
            missingLetterIndex: 2,
            missingLetter: "N",
            clueEmoji: "☀️",
            letterChoices: ["N", "G", "T", "P"]
        )
    ]

    var currentQuestion: WordQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            // Background environment gradient
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header & Progress
                ProgressBarView(
                    categoryTitle: "Complete the Word ",
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    promptText: "Fill in the missing letter! ",
                    onBackTapped: {
                        SoundManager.shared.stopAllAudio()
                        onBackToHome()
                    },
                    onSpeakTapped: {
                        SoundManager.shared.speak("Fill in the missing letter for \(currentQuestion.fullWord)")
                    }
                )

                Spacer()

                // Center Card: Picture Clue & Word Slot
                VStack(spacing: 24) {
                    // Clue Emoji Circle
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 140, height: 140)
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)

                        Text(currentQuestion.clueEmoji)
                            .font(.system(size: 80))
                    }

                    // Word Letters Display Slots
                    HStack(spacing: 14) {
                        let characters = Array(currentQuestion.fullWord)
                        ForEach(0..<characters.count, id: \.self) { index in
                            let char = characters[index]
                            let isMissingSlot = (index == currentQuestion.missingLetterIndex)

                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(isMissingSlot ? (isAnswerCorrect ? Color.green.opacity(0.2) : Color.yellow.opacity(0.3)) : Color.white)
                                    .frame(width: 75, height: 90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(isMissingSlot ? (isAnswerCorrect ? Color.green : Color.orange) : Color.gray.opacity(0.3), lineWidth: isMissingSlot ? 4 : 2)
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

                                if isMissingSlot {
                                    if let selected = selectedLetter, isAnswerCorrect {
                                        Text(String(selected))
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundColor(.green)
                                            .transition(.scale)
                                    } else {
                                        Text("_")
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundColor(.orange)
                                    }
                                } else {
                                    Text(String(char))
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                .padding(32)
                .frame(maxWidth: 700)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
                )

                Spacer()

                // Letter Choices Section
                VStack(spacing: 12) {
                    Text("Tap the correct letter below:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)

                    HStack(spacing: 24) {
                        ForEach(currentQuestion.letterChoices, id: \.self) { letter in
                            Button(action: {
                                handleLetterTap(letter)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.mint, .teal],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 90, height: 90)
                                        .shadow(color: Color.teal.opacity(0.4), radius: 8, x: 0, y: 4)

                                    Text(String(letter))
                                        .font(.system(size: 44, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.bottom, 36)
            }

            // Wrong Answer Feedback Toast Banner
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
                    .background(Capsule().fill(Color.pink))
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
        selectedLetter = nil
        isAnswerCorrect = false
        showWrongBanner = false
        SoundManager.shared.speak("Spell \(questions[index].fullWord)")
    }

    private func handleLetterTap(_ letter: Character) {
        selectedLetter = letter
        if HitTestEngine.evaluateWordLetter(selectedLetter: letter, missingLetter: currentQuestion.missingLetter) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isAnswerCorrect = true
            }
            SoundManager.shared.playCorrectFeedback()
            SoundManager.shared.speak("\(currentQuestion.fullWord)! Great job!")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Oops! '\(letter)' is not the right letter. Try again!")
        }
    }

    private func triggerWrongFeedback(message: String) {
        wrongMessage = message
        SoundManager.shared.playWrongFeedback()

        withAnimation {
            showWrongBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                showWrongBanner = false
            }
        }
    }

    private func advanceQuestion() {
        progressManager.markQuestionCompleted(category: .wordCompletion, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            // Finished all questions in Word Completion!
            progressManager.finishCategory(category: .wordCompletion)
            onFinishCategory()
        }
    }
}
