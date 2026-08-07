import SwiftUI

struct CardSelectionView: View {
    @ObservedObject var progressManager: GameProgressManager
    let onSelectCategory: (GameCategory) -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 16),
            count: horizontalSizeClass == .regular ? 2 : 1
        )
    }

    var body: some View {
        ZStack {
            GameScreenBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    GameFeatureHeader(
                        title: "Learning Games",
                        subtitle: "Choose a game and let the fun begin!",
                        icon: "gamecontroller.fill"
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pick Your Adventure")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(KidColors.darkText)
                        Text("Every game is a playful way to learn something new.")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(KidColors.softText)
                    }
                    .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(GameCategory.allCases) { category in
                            CategoryCard(
                                category: category,
                                completedCount: progressManager.completedQuestions[category] ?? 0,
                                stars: progressManager.starsEarned[category] ?? 0,
                                onTap: {
                                    onSelectCategory(category)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 40 : 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryCard: View {
    let category: GameCategory
    let completedCount: Int
    let stars: Int
    let onTap: () -> Void

    @State private var isPressed: Bool = false

    var isFinished: Bool {
        completedCount >= category.totalQuestions
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                onTap()
            }
        }) {
            VStack(alignment: .leading, spacing: 14) {
                // Card Top Icon & Badge
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.20))
                            .frame(width: 62, height: 62)
                            .overlay(Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1.5))

                        Image(systemName: category.icon)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    GradientBadge(
                        text: isFinished ? "DONE!" : "READY!",
                        colors: isFinished
                            ? [KidColors.sunshineYellow, KidColors.coralPink]
                            : [KidColors.skyBlue, KidColors.cosmicPurpleEnd],
                        fontSize: 10
                    )
                }

                // Title & Subtitle
                VStack(spacing: 8) {
                    Text(category.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)

                    Text(category.subtitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()

                // Progress Status Box
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        ForEach(0..<category.totalQuestions, id: \.self) { index in
                            Image(systemName: index < completedCount ? "star.fill" : "star")
                                .foregroundColor(index < completedCount ? .yellow : .white.opacity(0.5))
                                .font(.title3)
                        }
                    }

                    Text(isFinished ? "All questions completed" : "Progress: \(completedCount)/\(category.totalQuestions)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(isFinished ? .yellow : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.2))
                        )
                }

                // Play Button Pill
                HStack(spacing: 8) {
                    Text(isFinished ? "Replay Game" : (completedCount > 0 ? "Continue" : "Start Game"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(category.gradientColors.first ?? .purple)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 280)
            .background(
                LinearGradient(
                    colors: category.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: (category.gradientColors.first ?? .purple).opacity(0.35), radius: 14, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
