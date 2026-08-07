import SwiftUI

struct CountGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var currentObjects: [PlacedObject] = []
    @State private var countedCount: Int = 0
    @State private var totalTargetCount: Int = 0

    // Animation & Feedback states
    @State private var wrongTapLocation: CGPoint? = nil
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [CountQuestion] = [
        CountQuestion(
            title: "Count Objects ",
            promptText: "Count the apples! ",
            targetCriteriaDescription: "apples",
            objects: [
                PlacedObject(name: "Apple 1", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.25, y: 0.30)),
                PlacedObject(name: "Apple 2", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.45, y: 0.22)),
                PlacedObject(name: "Banana 1", emoji: "🍌", color: .yellow, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.68, y: 0.70)),
                PlacedObject(name: "Apple 3", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.35, y: 0.65)),
                PlacedObject(name: "Orange 1", emoji: "🍊", color: .orange, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.15, y: 0.72)),
                PlacedObject(name: "Apple 4", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.78, y: 0.32)),
                PlacedObject(name: "Apple 5", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.82, y: 0.68))
            ]
        ),
        CountQuestion(
            title: "Count Objects ",
            promptText: "Count ONLY the red apples! ",
            targetCriteriaDescription: "red apples",
            objects: [
                PlacedObject(name: "Red Apple 1", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.20, y: 0.28)),
                PlacedObject(name: "Green Apple 1", emoji: "🍏", color: .green, scale: 1.0, isOnTree: true, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.40, y: 0.20)),
                PlacedObject(name: "Red Apple 2", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.60, y: 0.28)),
                PlacedObject(name: "Green Apple 2", emoji: "🍏", color: .green, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.30, y: 0.65)),
                PlacedObject(name: "Red Apple 3", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.52, y: 0.68)),
                PlacedObject(name: "Red Apple 4", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.75, y: 0.62))
            ]
        ),
        CountQuestion(
            title: "Count Objects ",
            promptText: "Count the SMALL apples! ",
            targetCriteriaDescription: "small apples",
            objects: [
                PlacedObject(name: "Small Apple 1", emoji: "🍎", color: .red, scale: 0.65, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.22, y: 0.25)),
                PlacedObject(name: "Big Apple 1", emoji: "🍎", color: .red, scale: 1.35, isOnTree: true, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.48, y: 0.24)),
                PlacedObject(name: "Small Apple 2", emoji: "🍎", color: .red, scale: 0.65, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.72, y: 0.28)),
                PlacedObject(name: "Small Apple 3", emoji: "🍎", color: .red, scale: 0.65, isOnTree: false, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.28, y: 0.68)),
                PlacedObject(name: "Big Apple 2", emoji: "🍎", color: .red, scale: 1.35, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.65, y: 0.65))
            ]
        ),
        CountQuestion(
            title: "Count Objects ",
            promptText: "Count the apples ON THE TREE! ",
            targetCriteriaDescription: "apples on the tree",
            objects: [
                PlacedObject(name: "Tree Apple 1", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.25, y: 0.22)),
                PlacedObject(name: "Tree Apple 2", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.45, y: 0.18)),
                PlacedObject(name: "Tree Apple 3", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.65, y: 0.24)),
                PlacedObject(name: "Tree Apple 4", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: true, normalizedPosition: CGPoint(x: 0.80, y: 0.28)),
                PlacedObject(name: "Ground Apple 1", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.30, y: 0.72)),
                PlacedObject(name: "Ground Apple 2", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.60, y: 0.70))
            ]
        ),
        CountQuestion(
            title: "Count Objects ",
            promptText: "Count the apples WITH STARS!",
            targetCriteriaDescription: "apples with stars",
            objects: [
                PlacedObject(name: "Star Apple 1", emoji: "🍎", color: .red, scale: 1.1, isOnTree: true, hasStar: true, isTarget: true, normalizedPosition: CGPoint(x: 0.20, y: 0.25)),
                PlacedObject(name: "Plain Apple 1", emoji: "🍎", color: .red, scale: 1.0, isOnTree: true, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.42, y: 0.22)),
                PlacedObject(name: "Star Apple 2", emoji: "🍎", color: .red, scale: 1.1, isOnTree: true, hasStar: true, isTarget: true, normalizedPosition: CGPoint(x: 0.65, y: 0.26)),
                PlacedObject(name: "Plain Apple 2", emoji: "🍎", color: .red, scale: 1.0, isOnTree: false, hasStar: false, isTarget: false, normalizedPosition: CGPoint(x: 0.25, y: 0.68)),
                PlacedObject(name: "Star Apple 3", emoji: "🍎", color: .red, scale: 1.1, isOnTree: false, hasStar: true, isTarget: true, normalizedPosition: CGPoint(x: 0.50, y: 0.65)),
                PlacedObject(name: "Star Apple 4", emoji: "🍎", color: .red, scale: 1.1, isOnTree: false, hasStar: true, isTarget: true, normalizedPosition: CGPoint(x: 0.75, y: 0.68))
            ]
        )
    ]

    var currentQuestion: CountQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 12) {
                // Navigation & Progress Header
                ProgressBarView(
                    categoryTitle: "Count Objects ",
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

                // Progress Tracker Badge
                HStack(spacing: 12) {
                    Text("Progress: \(countedCount) of \(totalTargetCount) found")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.purple)

                    HStack(spacing: 4) {
                        ForEach(0..<totalTargetCount, id: \.self) { i in
                            Image(systemName: i < countedCount ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(i < countedCount ? .green : .gray.opacity(0.5))
                                .font(.title2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.9)))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Interactive Canvas with 1:1 container gesture hit testing
                GeometryReader { canvasGeometry in
                    ZStack {
                        // Tree Canopy visual
                        Image(systemName: "tree.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.green.opacity(0.4))
                            .frame(width: canvasGeometry.size.width * 0.9, height: canvasGeometry.size.height * 0.55)
                            .position(x: canvasGeometry.size.width * 0.5, y: canvasGeometry.size.height * 0.3)

                        // Ground Grass line
                        Rectangle()
                            .fill(Color.green.opacity(0.25))
                            .frame(width: canvasGeometry.size.width, height: 120)
                            .position(x: canvasGeometry.size.width * 0.5, y: canvasGeometry.size.height * 0.85)

                        // Objects rendered at normalized positions
                        ForEach(currentObjects) { object in
                            let posX = object.normalizedPosition.x * canvasGeometry.size.width
                            let posY = object.normalizedPosition.y * canvasGeometry.size.height

                            ZStack {
                                Circle()
                                    .fill(object.isCounted ? Color.green.opacity(0.25) : Color.white.opacity(0.95))
                                    .frame(width: 85 * object.scale, height: 85 * object.scale)
                                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)

                                Text(object.emoji)
                                    .font(.system(size: 48 * object.scale))

                                if object.hasStar {
                                    Text("⭐")
                                        .font(.system(size: 22))
                                        .offset(x: 24 * object.scale, y: -24 * object.scale)
                                }

                                if object.isCounted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(.green)
                                        .background(Circle().fill(Color.white))
                                }
                            }
                            .scaleEffect(object.isCounted ? 1.15 : 1.0)
                            .position(x: posX, y: posY)
                        }

                        // Wrong Tap Ripple effect feedback
                        if let wrongLoc = wrongTapLocation {
                            Circle()
                                .stroke(Color.red, lineWidth: 4)
                                .frame(width: 70, height: 70)
                                .position(wrongLoc)
                                .transition(.scale.combined(with: .opacity))
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

            // Wrong Answer Feedback Toast Banner
            if showWrongBanner {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        Text(wrongMessage)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.red))
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
        currentObjects = q.objects
        totalTargetCount = q.objects.filter { $0.isTarget }.count
        countedCount = 0
        showWrongBanner = false
        SoundManager.shared.speak(q.promptText)
    }

    /// Canvas 1:1 Hit Testing
    private func handleCanvasTapAt(_ tapPoint: CGPoint, canvasSize: CGSize) {
        if let tappedObject = HitTestEngine.findObjectAtTapLocation(
            tapPoint: tapPoint,
            canvasSize: canvasSize,
            objects: currentObjects
        ) {
            if tappedObject.isTarget {
                if let index = currentObjects.firstIndex(where: { $0.id == tappedObject.id }) {
                    if !currentObjects[index].isCounted {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            currentObjects[index].isCounted = true
                            countedCount += 1
                        }
                        SoundManager.shared.playCorrectFeedback()

                        if countedCount == totalTargetCount {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                advanceQuestion()
                            }
                        }
                    }
                }
            } else {
                triggerWrongFeedback(at: tapPoint, message: "Oops! That's not a \(currentQuestion.targetCriteriaDescription)! Look carefully!")
            }
        } else {
            triggerWrongFeedback(at: tapPoint, message: "Tap directly on one of the \(currentQuestion.targetCriteriaDescription)!")
        }
    }

    private func triggerWrongFeedback(at point: CGPoint, message: String) {
        wrongTapLocation = point
        wrongMessage = message
        SoundManager.shared.playWrongFeedback()

        withAnimation {
            showWrongBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showWrongBanner = false
                wrongTapLocation = nil
            }
        }
    }

    private func advanceQuestion() {
        progressManager.markQuestionCompleted(category: .counting, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .counting)
            onFinishCategory()
        }
    }
}
