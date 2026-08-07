import SwiftUI

struct OddOneGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false

    // Feedback states
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [OddOneQuestion] = [
        OddOneQuestion(
            promptText: "Which object is different? ",
            items: [
                OddOneItem(label: "Apple", emoji: "🍎", color: .red, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Apple", emoji: "🍎", color: .red, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Banana", emoji: "🍌", color: .yellow, scaleX: 1.0, isOddTarget: true),
                OddOneItem(label: "Apple", emoji: "🍎", color: .red, scaleX: 1.0, isOddTarget: false)
            ]
        ),
        OddOneQuestion(
            promptText: "Find the ONLY fruit! ",
            items: [
                OddOneItem(label: "Red Car", emoji: "🚗", color: .red, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Yellow Taxi", emoji: "🚕", color: .yellow, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Strawberry", emoji: "🍓", color: .pink, scaleX: 1.0, isOddTarget: true),
                OddOneItem(label: "Blue Bus", emoji: "🚙", color: .blue, scaleX: 1.0, isOddTarget: false)
            ]
        ),
        OddOneQuestion(
            promptText: "Find the ONLY BLUE object! ",
            items: [
                OddOneItem(label: "Red Circle", emoji: "🔴", color: .red, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Yellow Star", emoji: "🌟", color: .yellow, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Blue Dolphin", emoji: "🐬", color: .blue, scaleX: 1.0, isOddTarget: true),
                OddOneItem(label: "Orange Circle", emoji: "🟠", color: .orange, scaleX: 1.0, isOddTarget: false)
            ]
        ),
        OddOneQuestion(
            promptText: "Find the object FACING THE OTHER WAY! ",
            items: [
                OddOneItem(label: "Right Fish", emoji: "🐟", color: .cyan, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Left Fish", emoji: "🐠", color: .orange, scaleX: -1.0, isOddTarget: true),
                OddOneItem(label: "Right Fish", emoji: "🐟", color: .cyan, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Right Fish", emoji: "🐟", color: .cyan, scaleX: 1.0, isOddTarget: false)
            ]
        ),
        OddOneQuestion(
            promptText: "Find the object WITHOUT A SMILE! ",
            items: [
                OddOneItem(label: "Happy", emoji: "😀", color: .yellow, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Smiling", emoji: "😄", color: .yellow, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "Grinning", emoji: "😁", color: .yellow, scaleX: 1.0, isOddTarget: false),
                OddOneItem(label: "No Smile", emoji: "😐", color: .yellow, scaleX: 1.0, isOddTarget: true)
            ]
        )
    ]

    var currentQuestion: OddOneQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header & Progress Bar
                ProgressBarView(
                    categoryTitle: "Find Odd One ",
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

                // Question Prompt Card
                Text("Tap the odd item out:")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.pink)

                // 2x2 Grid of Option Cards
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(currentQuestion.items) { item in
                        Button(action: {
                            handleItemTap(item)
                        }) {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(selectedItemId == item.id ? (item.isOddTarget ? Color.green.opacity(0.25) : Color.red.opacity(0.25)) : Color.white)
                                        .frame(width: 140, height: 140)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedItemId == item.id ? (item.isOddTarget ? Color.green : Color.red) : item.color.opacity(0.4), lineWidth: selectedItemId == item.id ? 5 : 3)
                                        )

                                    Text(item.emoji)
                                        .font(.system(size: 80))
                                        .scaleEffect(x: item.scaleX, y: 1.0)
                                }

                                Text(item.label)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
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

            // Wrong Answer Toast Banner
            if showWrongBanner {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
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
        selectedItemId = nil
        isCorrect = false
        showWrongBanner = false
        SoundManager.shared.speak(questions[index].promptText)
    }

    private func handleItemTap(_ item: OddOneItem) {
        selectedItemId = item.id

        if item.isOddTarget {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCorrect = true
            }
            SoundManager.shared.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Not that one! Look for the item that is different!")
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
        progressManager.markQuestionCompleted(category: .findOddOne, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .findOddOne)
            onFinishCategory()
        }
    }
}
