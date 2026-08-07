import SwiftUI
import Combine

struct FastConfettiParticle {
    var xFraction: Double
    var yFraction: Double
    var size: Double
    var color: Color
    var speed: Double
}

struct ConfettiView: View {
    private let particles: [FastConfettiParticle] = {
        let colors: [Color] = [.red, .yellow, .green, .blue, .purple, .orange, .pink]
        return (0..<70).map { _ in
            FastConfettiParticle(
                xFraction: Double.random(in: 0.05...0.95),
                yFraction: Double.random(in: -1.0...0.0),
                size: Double.random(in: 10...22),
                color: colors.randomElement() ?? .yellow,
                speed: Double.random(in: 0.15...0.4)
            )
        }
    }()

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvasContext, size in
                let time = context.date.timeIntervalSinceReferenceDate

                for particle in particles {
                    // Compute animated y position seamlessly without view tree state updates
                    let progress = (particle.yFraction + time * particle.speed).truncatingRemainder(dividingBy: 1.3)
                    let currentY = (progress - 0.15) * size.height
                    let currentX = particle.xFraction * size.width + sin(time * 3 + particle.speed * 10) * 15

                    let rect = CGRect(
                        x: currentX - particle.size / 2,
                        y: currentY - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )

                    canvasContext.fill(Path(ellipseIn: rect), with: .color(particle.color))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
