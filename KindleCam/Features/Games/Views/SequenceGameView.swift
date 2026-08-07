import SwiftUI

struct SequenceGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var currentItems: [SequenceItem] = []
    @State private var expectedStepIndex: Int = 0

    // Feedback states
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [SequenceQuestion] = [
        SequenceQuestion(
            type: .leftToRight,
            title: "Sequence Game ",
            promptText: "Tap from LEFT to RIGHT! ",
            items: [
                SequenceItem(targetOrder: 0, label: "1st", emoji: "🍎", color: .red, scale: 1.0, normalizedPosition: CGPoint(x: 0.15, y: 0.5)),
                SequenceItem(targetOrder: 1, label: "2nd", emoji: "🍊", color: .orange, scale: 1.0, normalizedPosition: CGPoint(x: 0.32, y: 0.5)),
                SequenceItem(targetOrder: 2, label: "3rd", emoji: "🍋", color: .yellow, scale: 1.0, normalizedPosition: CGPoint(x: 0.50, y: 0.5)),
                SequenceItem(targetOrder: 3, label: "4th", emoji: "🍏", color: .green, scale: 1.0, normalizedPosition: CGPoint(x: 0.68, y: 0.5)),
                SequenceItem(targetOrder: 4, label: "5th", emoji: "🫐", color: .blue, scale: 1.0, normalizedPosition: CGPoint(x: 0.85, y: 0.5))
            ]
        ),
        SequenceQuestion(
            type: .smallestToBiggest,
            title: "Sequence Game ",
            promptText: "Tap from SMALLEST to BIGGEST! ",
            items: [
                SequenceItem(targetOrder: 0, label: "Tiny Mouse", emoji: "🐭", color: .pink, scale: 0.6, normalizedPosition: CGPoint(x: 0.45, y: 0.3)),
                SequenceItem(targetOrder: 1, label: "Cat", emoji: "🐱", color: .orange, scale: 0.8, normalizedPosition: CGPoint(x: 0.80, y: 0.35)),
                SequenceItem(targetOrder: 2, label: "Dog", emoji: "🐶", color: .yellow, scale: 1.0, normalizedPosition: CGPoint(x: 0.20, y: 0.65)),
                SequenceItem(targetOrder: 3, label: "Cow", emoji: "🐮", color: .green, scale: 1.25, normalizedPosition: CGPoint(x: 0.55, y: 0.68)),
                SequenceItem(targetOrder: 4, label: "Huge Elephant", emoji: "🐘", color: .blue, scale: 1.5, normalizedPosition: CGPoint(x: 0.85, y: 0.72))
            ]
        ),
        SequenceQuestion(
            type: .rainbowColors,
            title: "Sequence Game ",
            promptText: "Tap by RAINBOW colors! ",
            items: [
                SequenceItem(targetOrder: 0, label: "Red", emoji: "🔴", color: .red, scale: 1.1, normalizedPosition: CGPoint(x: 0.25, y: 0.35)),
                SequenceItem(targetOrder: 1, label: "Orange", emoji: "🟠", color: .orange, scale: 1.1, normalizedPosition: CGPoint(x: 0.60, y: 0.32)),
                SequenceItem(targetOrder: 2, label: "Yellow", emoji: "🟡", color: .yellow, scale: 1.1, normalizedPosition: CGPoint(x: 0.82, y: 0.40)),
                SequenceItem(targetOrder: 3, label: "Green", emoji: "🟢", color: .green, scale: 1.1, normalizedPosition: CGPoint(x: 0.18, y: 0.68)),
                SequenceItem(targetOrder: 4, label: "Blue", emoji: "🔵", color: .blue, scale: 1.1, normalizedPosition: CGPoint(x: 0.50, y: 0.70)),
                SequenceItem(targetOrder: 5, label: "Purple", emoji: "🟣", color: .purple, scale: 1.1, normalizedPosition: CGPoint(x: 0.78, y: 0.66))
            ]
        ),
        SequenceQuestion(
            type: .numbers1To5,
            title: "Sequence Game ",
            promptText: "Tap NUMBERS 1 to 5 in order!",
            items: [
                SequenceItem(targetOrder: 0, label: "1", emoji: "1️⃣", color: .red, scale: 1.2, normalizedPosition: CGPoint(x: 0.45, y: 0.65)),
                SequenceItem(targetOrder: 1, label: "2", emoji: "2️⃣", color: .orange, scale: 1.2, normalizedPosition: CGPoint(x: 0.22, y: 0.35)),
                SequenceItem(targetOrder: 2, label: "3", emoji: "3️⃣", color: .green, scale: 1.2, normalizedPosition: CGPoint(x: 0.78, y: 0.32)),
                SequenceItem(targetOrder: 3, label: "4", emoji: "4️⃣", color: .blue, scale: 1.2, normalizedPosition: CGPoint(x: 0.18, y: 0.70)),
                SequenceItem(targetOrder: 4, label: "5", emoji: "5️⃣", color: .purple, scale: 1.2, normalizedPosition: CGPoint(x: 0.75, y: 0.68))
            ]
        ),
        SequenceQuestion(
            type: .lifeCycle,
            title: "Sequence Game ",
            promptText: "Tap the LIFE CYCLE in order! (Seed → Plant → Flower) ",
            items: [
                SequenceItem(targetOrder: 0, label: "1. Seed", emoji: "🌱", color: .brown, scale: 1.2, normalizedPosition: CGPoint(x: 0.25, y: 0.50)),
                SequenceItem(targetOrder: 1, label: "2. Plant", emoji: "🪴", color: .green, scale: 1.2, normalizedPosition: CGPoint(x: 0.50, y: 0.50)),
                SequenceItem(targetOrder: 2, label: "3. Flower", emoji: "🌸", color: .pink, scale: 1.2, normalizedPosition: CGPoint(x: 0.75, y: 0.50))
            ]
        )
    ]

    var currentQuestion: SequenceQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 12) {
                // Header & Progress
                ProgressBarView(
                    categoryTitle: "Sequence Game",
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

                // Sequence Step Indicators
                HStack(spacing: 16) {
                    Text("Order Completed: \(expectedStepIndex) / \(currentItems.count)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.indigo)

                    HStack(spacing: 8) {
                        ForEach(0..<currentItems.count, id: \.self) { step in
                            ZStack {
                                Circle()
                                    .fill(step < expectedStepIndex ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 34, height: 34)

                                if step < expectedStepIndex {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } else {
                                    Text("\(step + 1)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.9)))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Sequence Board with 1:1 container gesture hit testing
                GeometryReader { canvasGeometry in
                    ZStack {
                        if currentQuestion.type == .leftToRight || currentQuestion.type == .lifeCycle {
                            Path { path in
                                path.move(to: CGPoint(x: canvasGeometry.size.width * 0.1, y: canvasGeometry.size.height * 0.5))
                                path.addLine(to: CGPoint(x: canvasGeometry.size.width * 0.9, y: canvasGeometry.size.height * 0.5))
                            }
                            .stroke(style: StrokeStyle(lineWidth: 6, dash: [10, 10]))
                            .foregroundColor(Color.indigo.opacity(0.3))
                        }

                        ForEach(currentItems) { item in
                            let posX = item.normalizedPosition.x * canvasGeometry.size.width
                            let posY = item.normalizedPosition.y * canvasGeometry.size.height

                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(item.isCompleted ? Color.green.opacity(0.2) : Color.white)
                                        .frame(width: 105 * item.scale, height: 105 * item.scale)
                                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(item.isCompleted ? Color.green : item.color, lineWidth: item.isCompleted ? 4 : 2)
                                        )

                                    Text(item.emoji)
                                        .font(.system(size: 54 * item.scale))

                                    if item.isCompleted {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(.green)
                                            .background(Circle().fill(Color.white))
                                    }
                                }

                                Text(item.label)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(item.isCompleted ? .green : .primary)
                            }
                            .scaleEffect(item.isCompleted ? 1.1 : 1.0)
                            .position(x: posX, y: posY)
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { gesture in
                                handleCanvasTapAt(gesture.location, canvasSize: canvasGeometry.size)
                            }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }

            // Wrong Answer Banner
            if showWrongBanner {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        Text(wrongMessage)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.orange))
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
        let q = questions[index]
        currentItems = q.items
        expectedStepIndex = 0
        showWrongBanner = false
        SoundManager.shared.speak(q.promptText)
    }

    private func handleCanvasTapAt(_ tapPoint: CGPoint, canvasSize: CGSize) {
        if let tappedItem = HitTestEngine.findSequenceItemAtTapLocation(
            tapPoint: tapPoint,
            canvasSize: canvasSize,
            items: currentItems
        ) {
            if HitTestEngine.evaluateSequenceTap(tappedItem: tappedItem, expectedOrderIndex: expectedStepIndex) {
                if let index = currentItems.firstIndex(where: { $0.id == tappedItem.id }) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        currentItems[index].isCompleted = true
                        expectedStepIndex += 1
                    }
                    SoundManager.shared.playCorrectFeedback()

                    if expectedStepIndex == currentItems.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            advanceQuestion()
                        }
                    }
                }
            } else {
                if tappedItem.isCompleted {
                    triggerWrongFeedback(message: "You already tapped that one! Find step \(expectedStepIndex + 1)!")
                } else {
                    triggerWrongFeedback(message: "Oops! Not that one yet! Follow the sequence order!")
                }
            }
        }
    }

    private func triggerWrongFeedback(message: String) {
        wrongMessage = message
        SoundManager.shared.playWrongFeedback()

        withAnimation {
            showWrongBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showWrongBanner = false
            }
        }
    }

    private func advanceQuestion() {
        progressManager.markQuestionCompleted(category: .sequence, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .sequence)
            onFinishCategory()
        }
    }
}
