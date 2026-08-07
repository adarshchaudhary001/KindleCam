import SwiftUI

struct AnimalGameView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onFinishCategory: () -> Void
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedItemId: UUID? = nil
    @State private var isCorrect: Bool = false
    @State private var showWrongBanner: Bool = false
    @State private var wrongMessage: String = ""

    private let questions: [AnimalQuestion] = [
        // Q1: Which animal says ROAR?
        AnimalQuestion(
            promptText: "Which animal says ROAR? ",
            items: [
                AnimalItem(name: "Duck", emoji: "🦆", soundText: "Quack!", habitat: "Pond", isCorrectTarget: false),
                AnimalItem(name: "Lion", emoji: "🦁", soundText: "ROAR!", habitat: "Savannah", isCorrectTarget: true),
                AnimalItem(name: "Frog", emoji: "🐸", soundText: "Ribbit!", habitat: "Pond", isCorrectTarget: false),
                AnimalItem(name: "Dog", emoji: "🐶", soundText: "Woof!", habitat: "Home", isCorrectTarget: false)
            ]
        ),
        // Q2: Find the animal that can FLY!
        AnimalQuestion(
            promptText: "Find the animal that can FLY! ",
            items: [
                AnimalItem(name: "Elephant", emoji: "🐘", soundText: "Trumpet!", habitat: "Land", isCorrectTarget: false),
                AnimalItem(name: "Cat", emoji: "🐱", soundText: "Meow!", habitat: "Home", isCorrectTarget: false),
                AnimalItem(name: "Eagle", emoji: "🦅", soundText: "Screech!", habitat: "Sky", isCorrectTarget: true),
                AnimalItem(name: "Fish", emoji: "🐟", soundText: "Blub!", habitat: "Water", isCorrectTarget: false)
            ]
        ),
        // Q3: Which animal lives in the OCEAN?
        AnimalQuestion(
            promptText: "Which animal lives in the OCEAN? ",
            items: [
                AnimalItem(name: "Rabbit", emoji: "🐰", soundText: "Hop!", habitat: "Burrow", isCorrectTarget: false),
                AnimalItem(name: "Dolphin", emoji: "🐬", soundText: "Click!", habitat: "Ocean", isCorrectTarget: true),
                AnimalItem(name: "Bear", emoji: "🐻", soundText: "Growl!", habitat: "Forest", isCorrectTarget: false),
                AnimalItem(name: "Chicken", emoji: "🐔", soundText: "Cluck!", habitat: "Farm", isCorrectTarget: false)
            ]
        ),
        // Q4: Find the BABY animal!
        AnimalQuestion(
            promptText: "Find the BABY animal! ",
            items: [
                AnimalItem(name: "Cow", emoji: "🐮", soundText: "Moo!", habitat: "Farm", isCorrectTarget: false),
                AnimalItem(name: "Horse", emoji: "🐴", soundText: "Neigh!", habitat: "Farm", isCorrectTarget: false),
                AnimalItem(name: "Tiger", emoji: "🐯", soundText: "Roar!", habitat: "Jungle", isCorrectTarget: false),
                AnimalItem(name: "Baby Chick", emoji: "🐣", soundText: "Cheep!", habitat: "Farm", isCorrectTarget: true)
            ]
        ),
        // Q5: Match animal to its favorite food!
        AnimalQuestion(
            promptText: "Match the Monkey to its favorite food! 🐵",
            items: [
                AnimalItem(name: "Fish 🐟", emoji: "🐟", soundText: "", habitat: "", isCorrectTarget: false),
                AnimalItem(name: "Banana 🍌", emoji: "🍌", soundText: "", habitat: "", isCorrectTarget: true),
                AnimalItem(name: "Grass 🌿", emoji: "🌿", soundText: "", habitat: "", isCorrectTarget: false),
                AnimalItem(name: "Carrot 🥕", emoji: "🥕", soundText: "", habitat: "", isCorrectTarget: false)
            ]
        )
    ]

    var currentQuestion: AnimalQuestion {
        questions[currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            VStack(spacing: 20) {
                // Header Bar
                ProgressBarView(
                    categoryTitle: "Animal World ",
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

                Text("Tap your answer:")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.orange)

                // 2x2 Grid of Option Cards
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
                                                .stroke(selectedItemId == item.id ? (item.isCorrectTarget ? Color.green : Color.red) : Color.orange.opacity(0.4), lineWidth: selectedItemId == item.id ? 5 : 3)
                                        )

                                    Text(item.emoji)
                                        .font(.system(size: 80))
                                }

                                Text(item.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)

                                if !item.soundText.isEmpty {
                                    Text("\"\(item.soundText)\"")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
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

            // Wrong Toast Banner
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
        selectedItemId = nil
        isCorrect = false
        showWrongBanner = false
        SoundManager.shared.speak(questions[index].promptText)
    }

    private func handleItemTap(_ item: AnimalItem) {
        selectedItemId = item.id

        if item.isCorrectTarget {
            withAnimation(.spring()) {
                isCorrect = true
            }
            if !item.soundText.isEmpty {
                SoundManager.shared.speak(item.soundText)
            }
            SoundManager.shared.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceQuestion()
            }
        } else {
            triggerWrongFeedback(message: "Not that one! Listen or look closely!")
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
        progressManager.markQuestionCompleted(category: .animalWorld, questionIndex: currentQuestionIndex)

        if currentQuestionIndex + 1 < questions.count {
            withAnimation {
                loadQuestion(index: currentQuestionIndex + 1)
            }
        } else {
            progressManager.finishCategory(category: .animalWorld)
            onFinishCategory()
        }
    }
}
