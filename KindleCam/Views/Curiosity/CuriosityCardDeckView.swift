//
//  CuriosityCardDeckView.swift
//  KindleCam
//
//  Interactive 3D Playing Card Deck View for Curiosity Cards.
//  Renders a stacked 3D physical card deck with shuffle animation.
//  Tapping "Shuffle" or the deck triggers a rapid card-riffle shuffle motion,
//  shuffles the cards randomly, and automatically scatters them into a swipable horizontal carousel!
//
//  Strictly no emojis — all visuals use SF Symbols and KidDesignSystem components.
//

import SwiftUI

public struct CuriosityCardDeckView: View {
    let questions: [CuriosityQuestion]
    @Bindable var viewModel: CuriosityCardsViewModel

    @State private var displayQuestions: [CuriosityQuestion] = []
    @State private var isExpanded = false
    @State private var isShuffling = false
    @State private var shuffleStep = 0

    public init(questions: [CuriosityQuestion], viewModel: CuriosityCardsViewModel) {
        self.questions = questions
        self.viewModel = viewModel
        self._displayQuestions = State(initialValue: questions)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Deck Control Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: isShuffling ? "shuffle.circle.fill" : (isExpanded ? "rectangle.stack.fill" : "square.stack.3d.up.fill"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KidColors.cosmicPurple, KidColors.coralPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(isShuffling ? Double(shuffleStep * 90) : 0))

                    Text(isShuffling ? "Shuffling Deck..." : (isExpanded ? "Swipable Card Deck" : "Interactive Card Deck"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.darkText)
                }

                Spacer()

                HStack(spacing: 8) {
                    // Shuffle Deck Button
                    Button(action: {
                        triggerShuffleDeck()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 13, weight: .bold))
                            Text("Shuffle")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [KidColors.sunshineYellow, KidColors.coralPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: KidColors.coralPink.opacity(0.35), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isShuffling || displayQuestions.isEmpty)

                    // Toggle Deck Expand / Stack button
                    Button(action: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isExpanded ? "square.stack.3d.down.right.fill" : "hand.tap.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(isExpanded ? "Stack" : "Scatter")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(KidColors.cosmicPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(KidColors.cosmicPurple.opacity(0.12))
                        )
                    }
                    .disabled(isShuffling)
                }
            }

            if displayQuestions.isEmpty {
                // Empty deck view
                emptyDeckView
            } else if !isExpanded || isShuffling {
                // COLLAPSED: Stacked physical card deck (or actively shuffling)
                stackedDeckView
            } else {
                // EXPANDED: Scattered horizontal card carousel
                scatteredDeckCarousel
            }
        }
        .onAppear {
            if displayQuestions.isEmpty && !questions.isEmpty {
                displayQuestions = questions
            }
        }
        .onChange(of: questions) { _, newQuestions in
            displayQuestions = newQuestions
        }
    }

    // MARK: - Stacked Deck View (Collapsed & Shuffling Animation State)

    private var stackedDeckView: some View {
        Button(action: {
            if !isShuffling {
                triggerShuffleDeck()
            }
        }) {
            ZStack {
                // Stacked background cards (up to 5 cards)
                ForEach(Array(displayQuestions.prefix(5).enumerated().reversed()), id: \.element.id) { index, q in
                    let theme = CardTheme.theme(for: q.category)

                    // Compute dynamic rotation and translation offsets during shuffle animation
                    let baseRotation = Double((index * 3) - 4)
                    let baseOffsetY = CGFloat(index * 8)
                    let baseOffsetX = CGFloat(index * 4)

                    // Dynamic shuffle offsets when shuffling
                    let shuffleAngle: Double = isShuffling ? ((index % 2 == 0 ? 1 : -1) * Double(shuffleStep * 7)) : 0
                    let shuffleX: CGFloat = isShuffling ? ((index % 2 == 0 ? 30 : -30) * CGFloat(shuffleStep % 2 == 0 ? 1 : -1)) : 0
                    let shuffleY: CGFloat = isShuffling ? (CGFloat(shuffleStep * 4) * (index % 2 == 0 ? -1 : 1)) : 0

                    MiniPlayingCard(question: q, viewModel: viewModel, theme: theme)
                        .frame(width: 240, height: 330)
                        .rotationEffect(.degrees(baseRotation + shuffleAngle))
                        .offset(x: baseOffsetX + shuffleX, y: baseOffsetY + shuffleY)
                        .shadow(color: theme.shadowColor.opacity(0.25), radius: 12, x: 0, y: 6)
                }

                // Interactive tap prompt overlay on top of stacked deck
                VStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: isShuffling ? "shuffle" : "hand.tap.fill")
                            .font(.system(size: 16, weight: .bold))
                            .rotationEffect(.degrees(isShuffling ? Double(shuffleStep * 120) : 0))

                        Text(isShuffling ? "Shuffling Cards..." : "Tap Deck to Shuffle & Spread Cards!")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [KidColors.cosmicPurple, KidColors.coralPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: KidColors.cosmicPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                    .padding(.bottom, 20)
                }
            }
            .frame(height: 380)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(KidPressButtonStyle())
    }

    // MARK: - Scattered Deck Carousel (Expanded Horizontal Swipe)

    private var scatteredDeckCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Swipe left or right to browse cards • Tap any card to flip & reveal answer")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(KidColors.softText)

                Spacer()

                Button(action: {
                    triggerShuffleDeck()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 11, weight: .bold))
                        Text("Reshuffle")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(KidColors.cosmicPurple)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(displayQuestions.enumerated()), id: \.element.id) { index, question in
                        let theme = CardTheme.theme(for: question.category)

                        NavigationLink(destination: CuriosityQuestionDetailView(question: question, viewModel: viewModel)) {
                            MiniPlayingCard(question: question, viewModel: viewModel, theme: theme)
                                .frame(width: 250, height: 350)
                                .shadow(color: theme.shadowColor.opacity(0.30), radius: 14, x: 0, y: 8)
                        }
                        .buttonStyle(KidPressButtonStyle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 14)
            }
        }
    }

    // MARK: - Empty Deck View

    private var emptyDeckView: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.stack.3d.up.slash.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [KidColors.sunshineYellow, KidColors.coralPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("No cards in this deck yet!")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(KidColors.softText)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .kidCardShadow()
        )
    }

    // MARK: - Card Shuffle Animation Sequence

    private func triggerShuffleDeck() {
        guard !isShuffling && !displayQuestions.isEmpty else { return }

        Task {
            // 1. Return to stacked view for shuffle motion
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isShuffling = true
                isExpanded = false
            }

            // 2. Play 5 fast riffle-shuffle keyframe steps
            for step in 1...5 {
                try? await Task.sleep(nanoseconds: 90_000_000) // 90ms per step
                withAnimation(.easeInOut(duration: 0.08)) {
                    shuffleStep = step
                }
            }

            // 3. Randomly shuffle the card deck
            displayQuestions.shuffle()

            // 4. Brief pause after shuffle completion
            try? await Task.sleep(nanoseconds: 120_000_000)

            // 5. Automatically scatter open into horizontal carousel
            withAnimation(.spring(response: 0.60, dampingFraction: 0.70)) {
                isShuffling = false
                shuffleStep = 0
                isExpanded = true
            }
        }
    }
}

// MARK: - Mini Playing Card Component

/// A mini thematic playing card designed specifically for the scattered deck carousel.
private struct MiniPlayingCard: View {
    let question: CuriosityQuestion
    @Bindable var viewModel: CuriosityCardsViewModel
    let theme: CardTheme

    var body: some View {
        VStack(spacing: 14) {
            // Top Bar: Category Pill + Answered Stamp
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: categoryIconName(for: question.category))
                        .font(.system(size: 11, weight: .bold))
                    Text(question.category.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: theme.bubbleColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )

                Spacer()

                if viewModel.isAnswered(question.id) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                } else if viewModel.isFavorite(question.id) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(KidColors.sunshineYellow)
                }
            }

            Spacer()

            // Center Question Bubble
            ThemedQuestionBubble(theme: theme, size: 44)

            // Question Text
            Text(question.question)
                .font(.system(size: 17, weight: .bold, design: theme.fontDesign))
                .foregroundStyle(theme.questionTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .lineLimit(4)
                .padding(.horizontal, 6)

            Spacer()

            // Bottom Prompt
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12, weight: .bold))
                Text(viewModel.isAnswered(question.id) ? "Review Answer" : "Tap to Flip")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.white.opacity(0.18))
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Themed gradient background
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: theme.frontGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Custom procedural grid/watermark overlay
                theme.customPatternOverlay
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            // Floating thematic decorations
            ThematicCardDecoration(theme: theme, isBackSide: false)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            // Themed border
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: theme.borderColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}
