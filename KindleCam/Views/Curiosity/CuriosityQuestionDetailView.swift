//
//  CuriosityQuestionDetailView.swift
//  KindleCam
//
//  Dedicated Question Detail screen displaying the interactive 3D flip card.
//  Front side shows the question; back side reveals the AI-generated answer.
//  Cached answers are displayed instantly on subsequent reviews.
//
//  Strictly no emojis — all visuals use SF Symbols, custom vector shapes,
//  and the KidDesignSystem components.
//

import SwiftUI

public struct CuriosityQuestionDetailView: View {
    let question: CuriosityQuestion
    @Bindable var viewModel: CuriosityCardsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var isFavorite: Bool = false

    private var isWide: Bool { sizeClass == .regular }

    public init(question: CuriosityQuestion, viewModel: CuriosityCardsViewModel) {
        self.question = question
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Category-specific ambient main background
            CardTheme.theme(for: question.category).mainScreenBackground

            VStack(spacing: 0) {
                // Custom Top Navigation Bar
                headerBar

                // Card area — uses GeometryReader to compute playing-card dimensions
                GeometryReader { geo in
                    let availW = max(0, geo.size.width - (isWide ? 160 : 40)) // horizontal padding
                    let availH = max(0, geo.size.height - 40)                 // vertical padding

                    // Playing card aspect ratio ~5:7 (width:height)
                    let cardAspect: CGFloat = 5.0 / 7.0

                    // In portrait: height-driven, capped by width
                    // In landscape: width-driven, capped by height
                    let heightFromWidth = availW / cardAspect
                    let widthFromHeight = availH * cardAspect

                    let isWidthLimited = heightFromWidth <= availH
                    let rawCardW = isWidthLimited ? availW : widthFromHeight
                    let rawCardH = isWidthLimited ? heightFromWidth : availH

                    let cardW = max(260, min(rawCardW, 500))
                    let cardH = max(360, min(rawCardH, 700))

                    VStack(spacing: 16) {
                        // Category Badge
                        categoryBadge

                        // 3D Flip Card — sized like a playing card
                        CuriosityCard3DView(question: question, viewModel: viewModel)
                            .frame(width: cardW, height: cardH)

                        // Fun tip
                        tipRow
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isFavorite = viewModel.isFavorite(question.id)
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                    Text("Back")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [KidColors.tropicalTeal, KidColors.skyBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                Text("Curiosity Card")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(KidColors.darkText)

            Spacer()

            // Favorite Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isFavorite.toggle()
                    viewModel.toggleFavorite(question.id)
                }
            }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        isFavorite
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [KidColors.sunshineYellow, KidColors.coralPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        : AnyShapeStyle(Color.gray.opacity(0.30))
                    )
                    .scaleEffect(isFavorite ? 1.15 : 1.0)
            }
        }
        .padding(.horizontal, isWide ? 40 : 20)
        .padding(.vertical, 14)
        .background(
            Color.white.opacity(0.75)
                .background(.ultraThinMaterial)
        )
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: categoryIconName(for: question.category))
                .font(.system(size: 14, weight: .bold))
            Text(question.category.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
        }
        .foregroundStyle(
            LinearGradient(
                colors: categoryColors(for: question.category),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(categoryColors(for: question.category).first?.opacity(0.10) ?? .clear)
        )
    }

    // MARK: - Tip Row

    private var tipRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(KidColors.cosmicPurple.opacity(0.5))

            Text("Tap the card to flip between question and answer!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(KidColors.softText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.7))
        )
    }
}
