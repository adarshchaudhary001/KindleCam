import SwiftUI

struct SizeGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    // State for Q3 ordering question
    @State private var orderedItemIds: [UUID] = []

    private let questions: [SizeQuestion] = [
        // Q1: Tap the biggest apple
        SizeQuestion(
            type: .tapBiggest,
            promptText: "Tap the BIGGEST apple!",
            items: [
                SizeItem(label: "Small Apple", emoji: "🍎", relativeSize: 0.55, heightRatio: 1.0, isTarget: false, correctOrder: 1),
                SizeItem(label: "Medium Apple", emoji: "🍎", relativeSize: 0.95, heightRatio: 1.0, isTarget: false, correctOrder: 2),
                SizeItem(label: "BIGGEST Apple", emoji: "🍎", relativeSize: 1.5, heightRatio: 1.0, isTarget: true, correctOrder: 3)
            ]
        ),
        // Q2: Tap the smallest apple
        SizeQuestion(
            type: .tapSmallest,
            promptText: "Tap the SMALLEST apple! ",
            items: [
                SizeItem(label: "Big Apple", emoji: "🍏", relativeSize: 1.45, heightRatio: 1.0, isTarget: false, correctOrder: 3),
                SizeItem(label: "SMALLEST Apple", emoji: "🍏", relativeSize: 0.45, heightRatio: 1.0, isTarget: true, correctOrder: 1),
                SizeItem(label: "Medium Apple", emoji: "🍏", relativeSize: 0.9, heightRatio: 1.0, isTarget: false, correctOrder: 2)
            ]
        ),
        // Q3: Arrange from small to big
        SizeQuestion(
            type: .arrangeSmallToBig,
            promptText: "Arrange from SMALL to BIG! ",
            items: [
                SizeItem(label: "Big Cat", emoji: "🐱", relativeSize: 1.4, heightRatio: 1.0, isTarget: false, correctOrder: 3),
                SizeItem(label: "Small Cat", emoji: "🐱", relativeSize: 0.5, heightRatio: 1.0, isTarget: false, correctOrder: 1),
                SizeItem(label: "Medium Cat", emoji: "🐱", relativeSize: 0.95, heightRatio: 1.0, isTarget: false, correctOrder: 2)
            ]
        ),
        // Q4: Which one is taller?
        SizeQuestion(
            type: .compareTaller,
            promptText: "Which one is TALLER? ",
            items: [
                SizeItem(label: "Puppy", emoji: "🐶", relativeSize: 1.0, heightRatio: 0.9, isTarget: false, correctOrder: 1),
                SizeItem(label: "Giraffe", emoji: "🦒", relativeSize: 1.0, heightRatio: 2.2, isTarget: true, correctOrder: 2)
            ]
        ),
        // Q5: Which one is shorter?
        SizeQuestion(
            type: .compareShorter,
            promptText: "Which one is SHORTER? ",
            items: [
                SizeItem(label: "Tall Tree", emoji: "🌲", relativeSize: 1.0, heightRatio: 2.4, isTarget: false, correctOrder: 2),
                SizeItem(label: "Short Bunny", emoji: "🐰", relativeSize: 1.0, heightRatio: 0.9, isTarget: true, correctOrder: 1)
            ]
        )
    ]

    var currentQuestion: SizeQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header Bar
                ProgressBarView(
                    categoryTitle: "Bigger or Smaller ",
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

                // Display options
                if currentQuestion.type == .arrangeSmallToBig {
                    VStack(spacing: 24) {
                        Text("Tap in order: 1st Smallest ➔ 2nd Medium ➔ 3rd Biggest")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.teal)

                        HStack(spacing: 32) {
                            ForEach(currentQuestion.items) { item in
                                Button(action: {
                                    handleOrderingTap(item)
                                }) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 140, height: 140)
                                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                                .overlay(
                                                    Circle()
                                                        .stroke(orderedItemIds.contains(item.id) ? Color.green : Color.teal.opacity(0.4), lineWidth: orderedItemIds.contains(item.id) ? 4 : 2)
                                                )

                                            Text(item.emoji)
                                                .font(.system(size: 70 * item.relativeSize))
                                        }
                                        .frame(width: 140, height: 140)
                                        .overlay(alignment: .topTrailing) {
                                            if let orderIndex = orderedItemIds.firstIndex(of: item.id) {
                                                Text("\(orderIndex + 1)")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .frame(width: 32, height: 32)
                                                    .background(Circle().fill(Color.green))
                                                    .offset(x: 4, y: -4)
                                            }
                                        }

                                        Text(item.label)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                } else if currentQuestion.type == .compareTaller || currentQuestion.type == .compareShorter {
                    // Height comparison side-by-side
                    HStack(spacing: 48) {
                        ForEach(currentQuestion.items) { item in
                            Button(action: {
                                handleSingleTap(item)
                            }) {
                                VStack(spacing: 16) {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(selectedItemId == item.id ? (item.isTarget ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                            .frame(width: 180, height: 260)
                                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(selectedItemId == item.id ? (item.isTarget ? Color.green : Color.red) : Color.teal.opacity(0.3), lineWidth: selectedItemId == item.id ? 4 : 2)
                                            )

                                        Text(item.emoji)
                                            .font(.system(size: 60 * item.heightRatio))
                                            .padding(.bottom, 20)
                                    }
                                    .frame(width: 180, height: 260)

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
                    // Size comparison (Biggest / Smallest apple)
                    HStack(spacing: 36) {
                        ForEach(currentQuestion.items) { item in
                            Button(action: {
                                handleSingleTap(item)
                            }) {
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedItemId == item.id ? (item.isTarget ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white)
                                            .frame(width: 160, height: 160)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedItemId == item.id ? (item.isTarget ? Color.green : Color.red) : Color.teal.opacity(0.3), lineWidth: selectedItemId == item.id ? 4 : 2)
                                            )

                                        Text(item.emoji)
                                            .font(.system(size: 70 * item.relativeSize))
                                    }
                                    .frame(width: 160, height: 160)

                                    Text(item.label)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
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
                    .background(Capsule().fill(Color.teal))
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
        orderedItemIds = []
        isCorrect = false
        showWrongBanner = false
        SoundManager.shared.speak(questions[index].promptText)
    }

    private func handleSingleTap(_ item: SizeItem) {
        selectedItemId = item.id

        if item.isTarget {
            withAnimation(.spring()) {
                isCorrect = true
            }
            SoundManager.shared.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Look closely at the size and try again!")
        }
    }

    private func handleOrderingTap(_ item: SizeItem) {
        if orderedItemIds.contains(item.id) { return }

        let nextOrder = orderedItemIds.count + 1
        if item.correctOrder == nextOrder {
            orderedItemIds.append(item.id)
            SoundManager.shared.playCorrectFeedback()

            if orderedItemIds.count == currentQuestion.items.count {
                withAnimation(.spring()) {
                    isCorrect = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    advanceQuestion()
                }
            }
        } else {
            triggerWrongFeedback(message: "Not that size! Tap from smallest to biggest!")
            orderedItemIds = []
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
        progressManager.markQuestionCompleted(category: .sizeComparison, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .sizeComparison)
            onFinishCategory()
        }
    }
}
