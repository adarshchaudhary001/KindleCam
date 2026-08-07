//
//  CuriosityCard3DView.swift
//  KindleCam
//
//  Interactive 2-sided 3D flashcard component for Curiosity Cards.
//  Each category has a unique thematic card design:
//    Space   — deep cosmic purple/indigo with floating stars, planets, and moons
//    Nature  — rich forest green with floating leaves, raindrops, and suns
//    Animals — warm coral/brown with floating pawprints, birds, and fish
//    Human Body — rose/magenta with floating hearts, brains, and eyes
//    Science — deep electric blue with floating atoms, bolts, and flasks
//
//  Front side: Themed question card with category decorations.
//  Back side: Themed AI answer card with matching accents.
//  Smooth 180° 3D rotation animation on tap, with a playful themed
//  loading state while the AI generates an answer.
//

import SwiftUI

public struct CuriosityCard3DView: View {
    let question: CuriosityQuestion
    @Bindable var viewModel: CuriosityCardsViewModel

    @State private var isFlipped = false
    @State private var cardAngle: Double = 0
    @State private var answerText: String = ""
    @State private var isLoadingAnswer = true
    @State private var isFavorite = false
    @State private var hasLoadedAnswer = false

    /// The category-specific visual theme for this card.
    private var theme: CardTheme {
        CardTheme.theme(for: question.category)
    }

    public init(question: CuriosityQuestion, viewModel: CuriosityCardsViewModel) {
        self.question = question
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // FRONT SIDE — Question Card
            frontSide
                .opacity(cardAngle < 90 ? 1 : 0)
                .accessibilityHidden(isFlipped)

            // BACK SIDE — Answer Card (pre-rotated 180° so text reads correctly after flip)
            backSide
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(cardAngle >= 90 ? 1 : 0)
                .accessibilityHidden(!isFlipped)
        }
        .rotation3DEffect(.degrees(cardAngle), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            flipCard()
        }
        .onAppear {
            isFavorite = viewModel.isFavorite(question.id)
            loadAnswer()
        }
        .onDisappear {
            SoundManager.shared.stopAllAudio()
        }
    }

    // MARK: - Front Side (Themed Question)

    private var frontSide: some View {
        VStack(spacing: 20) {
            // Top row: Category pill + Favorite
            HStack {
                // Category pill
                HStack(spacing: 6) {
                    Image(systemName: categoryIconName(for: question.category))
                        .font(.system(size: 14, weight: .bold))
                    Text(question.category.uppercased())
                        .font(.system(size: 12, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: theme.bubbleColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())

                Spacer()

                // Favorite button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isFavorite.toggle()
                        viewModel.toggleFavorite(question.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            isFavorite
                            ? LinearGradient(colors: [KidColors.sunshineYellow, KidColors.coralPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .scaleEffect(isFavorite ? 1.15 : 1.0)
                }
            }

            Spacer()

            // Themed question mark bubble
            ThemedQuestionBubble(theme: theme, size: 56)

            // Question text
            Text(question.question)
                .font(.system(size: 24, weight: .bold, design: theme.fontDesign))
                .foregroundStyle(theme.questionTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            Spacer()

            // Tap-to-flip action bar
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .bold))
                Text("Tap to Flip & Reveal Answer")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(.white.opacity(0.15))
                    .overlay(
                        Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Themed gradient background & procedural watermark/grid overlay
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: theme.frontGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                theme.customPatternOverlay

                // Subtle inner highlight glow
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.08), .clear],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 250
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            // Floating thematic decorations
            ThematicCardDecoration(theme: theme, isBackSide: false)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        )
        .overlay(
            // Themed border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: theme.borderColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 10)
    }

    // MARK: - Back Side (Themed Answer)

    private var backSide: some View {
        VStack(spacing: 20) {
            // Top badge
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                    Text("AI ANSWER")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColorSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())

                Spacer()

                // Answered stamp
                if !isLoadingAnswer {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Answered")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(theme.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.accentColor.opacity(0.10))
                    .clipShape(Capsule())
                }
            }

            Spacer()

            if isLoadingAnswer {
                ThemedMagicLoadingView(theme: theme)
            } else {
                // Answer text
                ScrollView(.vertical, showsIndicators: false) {
                    Text(answerText)
                        .font(.system(size: 20, weight: .medium, design: theme.fontDesign))
                        .foregroundStyle(theme.answerTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 8)
                }
            }

            Spacer()

            // Bottom action bar
            HStack(spacing: 12) {
                // Read aloud button
                Button(action: {
                    guard !isLoadingAnswer else { return }
                    SoundManager.shared.speak(answerText)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Read Aloud")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(theme.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.accentColor.opacity(0.10))
                    .clipShape(Capsule())
                }
                .buttonStyle(KidPressButtonStyle())
                .disabled(isLoadingAnswer)

                Spacer()

                // Flip back button
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .bold))
                    Text("Flip Back")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(theme.answerTextColor.opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(theme.accentColor.opacity(0.06))
                .clipShape(Capsule())
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: theme.backGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                theme.customPatternOverlay
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            // Floating thematic decorations (lighter on back)
            ThematicCardDecoration(theme: theme, isBackSide: true)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        )
        .overlay(
            // Themed border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: theme.borderColors.map { $0.opacity(0.5) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: theme.shadowColor.opacity(0.6), radius: 16, x: 0, y: 8)
    }

    // MARK: - Flip Logic

    private func flipCard() {
        let target: Double = isFlipped ? 0 : 180
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
            cardAngle = target
        }
        isFlipped.toggle()
    }

    // MARK: - Answer Loading

    private func loadAnswer() {
        guard !hasLoadedAnswer else { return }
        hasLoadedAnswer = true

        // Check for cached answer first (instant, no loading state needed)
        if let cached = viewModel.getCachedAnswer(for: question.id) {
            answerText = cached
            isLoadingAnswer = false
            return
        }

        // Generate answer via AI
        Task {
            let answer = await viewModel.fetchAnswer(for: question)
            withAnimation(.easeInOut(duration: 0.3)) {
                answerText = answer
                isLoadingAnswer = false
            }
        }
    }
}
