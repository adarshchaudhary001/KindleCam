import SwiftUI

struct CheerFeedbackView: View {
    let category: GameCategory
    let onBackToCardSelection: () -> Void

    @State private var scaleTitle: Bool = false
    @State private var showStars: Bool = false

    var body: some View {
        ZStack {
            GameScreenBackground()

            // Animated Confetti Fall
            ConfettiView()

            VStack(spacing: 24) {
                Spacer()

                // Big Floating Trophy & Stars
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [KidColors.sunshineYellow, KidColors.coralPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 132, height: 132)
                        .shadow(color: KidColors.sunshineYellow.opacity(0.35), radius: 12, x: 0, y: 6)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 62, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(scaleTitle ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: scaleTitle)
                }

                // Cheer Title & Announcement
                VStack(spacing: 12) {
                    GradientBadge(
                        text: "AMAZING!",
                        colors: [KidColors.sunshineYellow, KidColors.coralPink],
                        fontSize: 13
                    )

                    Text("You did it!")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KidColors.cosmicPurple, KidColors.coralPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(category.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.softText)

                    Text("You completed every question.")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(KidColors.softText)
                }
                .multilineTextAlignment(.center)

                // 3 Gold Stars Badge Row
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(KidColors.sunshineYellow)
                            .shadow(color: KidColors.sunshineYellow.opacity(0.55), radius: 10, x: 0, y: 5)
                            .scaleEffect(showStars ? 1.0 : 0.1)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.2), value: showStars)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 26)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.82))
                        .overlay(Capsule().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                )

                Spacer()

                // Back to Card Selection Button
                Button(action: {
                    SoundManager.shared.stopAllAudio()
                    onBackToCardSelection()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .font(.title)
                        Text("Back to Card Selection")
                            .font(.title2)
                            .fontWeight(.black)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [KidColors.cosmicPurple, KidColors.cosmicPurpleEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: KidColors.cosmicPurple.opacity(0.30), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(KidPressButtonStyle())
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            scaleTitle = true
            showStars = true
            SoundManager.shared.playCategoryCompletedCheer()
        }
        .onDisappear {
            SoundManager.shared.stopAllAudio()
        }
    }
}
