import SwiftUI

/// Shared KindleCam visual language for every game screen.
struct GameScreenBackground: View {
    var body: some View {
        KidBackgroundView(variant: .home)
    }
}

struct GameFeatureHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [KidColors.skyBlue, KidColors.cosmicPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [KidColors.cosmicPurple, KidColors.coralPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(KidColors.softText)
            }

            Spacer()

            GradientBadge(
                text: "PLAY!",
                colors: [KidColors.sunshineYellow, KidColors.coralPink]
            )
        }
    }
}
