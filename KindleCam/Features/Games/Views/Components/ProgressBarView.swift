import SwiftUI

struct ProgressBarView: View {
    let categoryTitle: String
    let currentQuestionIndex: Int
    let totalQuestions: Int
    let promptText: String
    let onBackTapped: () -> Void
    let onSpeakTapped: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            // Top Bar
            HStack {
                VStack(spacing: 2) {
                    Text(categoryTitle)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KidColors.cosmicPurple, KidColors.coralPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("Let’s play and learn!")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(KidColors.softText)
                }

                Spacer()

                // Question Counter Badge
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(KidColors.sunshineYellow)
                        .font(.system(size: 16, weight: .bold))
                    Text("Question \(currentQuestionIndex + 1)/\(totalQuestions)")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(KidColors.cosmicPurple)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white.opacity(0.92))
                .clipShape(Capsule())
                .kidCardShadow(radius: 6, y: 3)
            }

            // Progress Bar Track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 14)

                    let progressFraction = CGFloat(currentQuestionIndex + 1) / CGFloat(totalQuestions)
                    Capsule()
                        .fill(
                            LinearGradient(
                        colors: [KidColors.sunshineYellow, KidColors.coralPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progressFraction), height: 14)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentQuestionIndex)
                }
            }
            .frame(height: 14)

            // Prompt Card with Audio Speak button
            HStack(spacing: 12) {
                Button(action: onSpeakTapped) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.orange))
                        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
                }

                Text(promptText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.15))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(.white.opacity(0.70), lineWidth: 1)
                    )
                    .shadow(color: KidColors.cosmicPurple.opacity(0.12), radius: 10, x: 0, y: 5)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}
