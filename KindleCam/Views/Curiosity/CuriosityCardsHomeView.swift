//
//  CuriosityCardsHomeView.swift
//  KindleCam
//
//  Main entry View for the Curiosity Cards feature.
//  Displays the deterministic Daily Wonder hero banner, category filter pills,
//  mode filter segment (Explore, Answered History, Starred), and physical card deck system.
//
//  iPad-first responsive layout with native NavigationLink transitions for card detail presentation.
//
//  Strictly no emojis — all visuals use SF Symbols, custom vector shapes,
//  and the KidDesignSystem components.
//

import SwiftUI
import SwiftData

public struct CuriosityCardsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var viewModel = CuriosityCardsViewModel()

    private let categories = ["All", "Space", "Nature", "Animals", "Human Body", "Science"]

    private var isWide: Bool { sizeClass == .regular }

    public init() {}

    public var body: some View {
        ZStack {
            // Animated kid background
            KidBackgroundView(variant: .curiosity)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: isWide ? 28 : 22) {
                    // Header
                    headerSection

                    // Mode Filter Segment (Explore, Answered History, Starred)
                    modeFilterSection

                    // Daily Wonder Hero Card (shown in Explore mode)
                    if viewModel.filterMode == .explore, let dailyWonder = viewModel.dailyWonderQuestion {
                        dailyWonderCard(dailyWonder)
                    }

                    // Category Filter Pills
                    categoryPillsSection

                    // Question Cards Section (Explore, Answered, or Favorites)
                    questionsListSection
                }
                .padding(.horizontal, isWide ? 40 : 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 14) {
            // Vector icon instead of SF Symbol circle
            CategoryVectorIcon(category: "All", size: isWide ? 28 : 24, showBackground: true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Curiosity Cards")
                        .font(.system(size: isWide ? 32 : 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KidColors.tropicalTeal, KidColors.skyBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    SparkleVector(size: isWide ? 22 : 18, color: KidColors.sunshineYellow)
                }

                Text("Explore & Wonder Everyday!")
                    .font(.system(size: isWide ? 16 : 14, weight: .medium, design: .rounded))
                    .foregroundStyle(KidColors.softText)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Daily Wonder Hero Card

    private func dailyWonderCard(_ question: CuriosityQuestion) -> some View {
        NavigationLink(destination: CuriosityQuestionDetailView(question: question, viewModel: viewModel)) {
            VStack(alignment: .leading, spacing: 16) {
                // Top Row: Badge + Answered
                HStack {
                    // Badge with sparkle vector instead of 🌟
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("DAILY WONDER")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [KidColors.sunshineYellow, KidColors.coralPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: KidColors.sunshineYellow.opacity(0.4), radius: 4, x: 0, y: 2)

                    Spacer()

                    if viewModel.isAnswered(question.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Answered")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.22))
                        .clipShape(Capsule())
                    }
                }

                // Question Text
                Text(question.question)
                    .font(.system(size: isWide ? 26 : 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)

                // Decorative divider dots
                HStack(spacing: 4) {
                    ForEach(0..<6) { _ in
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 4, height: 4)
                    }
                }

                // Action Indicator
                HStack {
                    Text("Discover Today's Wonder")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.18))
                        .overlay(
                            Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .padding(22)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [KidColors.tropicalTeal, KidColors.tropicalTealEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RadialGradient(
                        colors: [.white.opacity(0.10), .clear],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 200
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: KidColors.tropicalTeal.opacity(0.30), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(KidPressButtonStyle())
    }

    // MARK: - Category Pills Section

    private var categoryPillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { cat in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectCategory(cat)
                        }
                    }) {
                        HStack(spacing: 6) {
                            // Vector category icon instead of emoji
                            Image(systemName: categoryIconName(for: cat))
                                .font(.system(size: 13, weight: .bold))
                            Text(cat)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(
                            viewModel.selectedCategory == cat
                            ? .white
                            : KidColors.tropicalTeal
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    viewModel.selectedCategory == cat
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: categoryColors(for: cat),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.white)
                                )
                                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(KidPressButtonStyle())
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private func categoryIconName(for category: String) -> String {
        switch category {
        case "Space": return "sparkles"
        case "Nature": return "leaf.fill"
        case "Animals": return "pawprint.fill"
        case "Human Body": return "heart.fill"
        case "Science": return "atom"
        default: return "square.grid.2x2.fill"
        }
    }

    private func categoryColors(for category: String) -> [Color] {
        switch category {
        case "Space": return [KidColors.cosmicPurple, KidColors.cosmicPurpleEnd]
        case "Nature": return [KidColors.tropicalTeal, KidColors.mintGreen]
        case "Animals": return [KidColors.sunshineYellow, KidColors.coralPink]
        case "Human Body": return [KidColors.coralPink, KidColors.roseGold]
        case "Science": return [KidColors.skyBlue, KidColors.tropicalTeal]
        default: return [KidColors.tropicalTeal, KidColors.skyBlue]
        }
    }

    // MARK: - Mode Filter Section (Explore, Answered History, Starred)

    private var modeFilterSection: some View {
        HStack(spacing: 8) {
            modeFilterButton(title: "Explore", icon: "sparkles", mode: .explore, count: nil)
            modeFilterButton(title: "Answered", icon: "checkmark.seal.fill", mode: .answered, count: viewModel.answeredQuestionsList.count)
            modeFilterButton(title: "Starred", icon: "star.fill", mode: .favorites, count: viewModel.favoriteQuestionsList.count)
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func modeFilterButton(title: String, icon: String, mode: CuriosityCardsViewModel.ViewFilterMode, count: Int?) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                viewModel.filterMode = mode
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                if let count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(viewModel.filterMode == mode ? KidColors.cosmicPurple : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(viewModel.filterMode == mode ? .white : KidColors.cosmicPurple)
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(viewModel.filterMode == mode ? .white : KidColors.darkText)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(
                        viewModel.filterMode == mode
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [KidColors.cosmicPurple, KidColors.cosmicPurpleEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyShapeStyle(Color.clear)
                    )
            )
        }
    }

    // MARK: - Dynamic Questions List Section

    private var displayQuestions: [CuriosityQuestion] {
        switch viewModel.filterMode {
        case .explore:
            return viewModel.curiosityQuestions
        case .answered:
            return viewModel.answeredQuestionsList
        case .favorites:
            return viewModel.favoriteQuestionsList
        }
    }

    private var sectionHeaderTitle: String {
        switch viewModel.filterMode {
        case .explore:
            return "Curious Minds"
        case .answered:
            return "Answered Collection"
        case .favorites:
            return "Starred Questions"
        }
    }

    private var sectionHeaderIcon: String {
        switch viewModel.filterMode {
        case .explore:
            return "lightbulb.fill"
        case .answered:
            return "checkmark.seal.fill"
        case .favorites:
            return "star.fill"
        }
    }

    private var emptyStateIcon: String {
        switch viewModel.filterMode {
        case .explore: return "party.popper.fill"
        case .answered: return "clock.arrow.circlepath"
        case .favorites: return "star.slash.fill"
        }
    }

    private var emptyStateText: String {
        switch viewModel.filterMode {
        case .explore:
            return "You've answered all questions in this category!"
        case .answered:
            return "No answered questions yet. Tap any card to discover!"
        case .favorites:
            return "No starred questions yet. Tap the star on any card!"
        }
    }

    @ViewBuilder
    private var questionsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title (Shown in Answered Collection or Starred mode)
            if viewModel.filterMode != .explore {
                HStack(spacing: 8) {
                    Image(systemName: sectionHeaderIcon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KidColors.sunshineYellow, KidColors.coralPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(sectionHeaderTitle)
                        .font(.system(size: isWide ? 22 : 19, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.darkText)

                    Text("(\(displayQuestions.count))")
                        .font(.system(size: isWide ? 16 : 14, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.softText)
                }
            }

            if displayQuestions.isEmpty {
                // Empty state for answered or favorites filter
                VStack(spacing: 12) {
                    Image(systemName: emptyStateIcon)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(KidColors.softText.opacity(0.5))

                    Text(emptyStateText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(KidColors.softText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                )
            } else if viewModel.filterMode == .explore {
                // EXPLORE MODE: Physical 3D playing card deck system
                CuriosityCardDeckView(
                    questions: displayQuestions,
                    viewModel: viewModel
                )
            } else {
                // ANSWERED / STARRED MODE: Responsive Grid layout with NavigationLinks
                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]

                LazyVGrid(columns: isWide ? columns : [GridItem(.flexible())], spacing: 16) {
                    ForEach(displayQuestions, id: \.id) { question in
                        NavigationLink(destination: CuriosityQuestionDetailView(question: question, viewModel: viewModel)) {
                            questionCardRow(question)
                        }
                        .buttonStyle(KidPressButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Question Card Row (Thematic Design)

    private func questionCardRow(_ question: CuriosityQuestion) -> some View {
        let rowTheme = CardTheme.theme(for: question.category)

        return HStack(spacing: 0) {
            // Themed left edge accent strip
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [rowTheme.accentColor, rowTheme.accentColorSecondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)
                .padding(.vertical, 8)

            HStack(spacing: 14) {
                // Vector category icon
                CategoryVectorIcon(
                    category: question.category,
                    size: 22,
                    showBackground: true
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(question.question)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.darkText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        // Category label with icon
                        HStack(spacing: 4) {
                            Image(systemName: categoryIconName(for: question.category))
                                .font(.system(size: 10, weight: .bold))
                            Text(question.category)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [rowTheme.accentColor, rowTheme.accentColorSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                        if viewModel.isFavorite(question.id) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(KidColors.sunshineYellow)
                        }
                    }
                }

                Spacer()

                // Answered status
                if viewModel.isAnswered(question.id) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [rowTheme.accentColor, rowTheme.accentColorSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(rowTheme.accentColor.opacity(0.25))
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            rowTheme.accentColor.opacity(0.04),
                            Color.white
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .kidCardShadow(color: rowTheme.shadowColor.opacity(0.4), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            rowTheme.accentColor.opacity(viewModel.isAnswered(question.id) ? 0.25 : 0.10),
                            rowTheme.accentColorSecondary.opacity(viewModel.isAnswered(question.id) ? 0.15 : 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        CuriosityCardsHomeView()
    }
    .modelContainer(AppModelContainer.previewContainer())
}
