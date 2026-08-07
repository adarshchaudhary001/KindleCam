//
//  KidDesignSystem.swift
//  KindleCam
//
//  Centralised design system for the kid-friendly KindleCam UI.
//  Contains vector-based category icons (strictly no emojis),
//  vibrant kid color palettes, animated background decorations,
//  and reusable button styles.
//

import SwiftUI

// MARK: - Kid Color Palette

/// Curated, vibrant color palette designed for children.
public enum KidColors {
    // Primary feature gradients
    static let cosmicPurple     = Color(red: 0.48, green: 0.24, blue: 0.93)
    static let cosmicPurpleEnd  = Color(red: 0.62, green: 0.36, blue: 0.98)
    static let tropicalTeal     = Color(red: 0.06, green: 0.72, blue: 0.50)
    static let tropicalTealEnd  = Color(red: 0.10, green: 0.82, blue: 0.60)
    static let coralPink        = Color(red: 1.00, green: 0.35, blue: 0.35)
    static let coralPinkEnd     = Color(red: 1.00, green: 0.52, blue: 0.38)
    static let sunshineYellow   = Color(red: 1.00, green: 0.78, blue: 0.10)
    static let sunshineYellowEnd = Color(red: 1.00, green: 0.88, blue: 0.30)
    static let skyBlue          = Color(red: 0.30, green: 0.70, blue: 1.00)
    static let skyBlueEnd       = Color(red: 0.50, green: 0.82, blue: 1.00)
    static let mintGreen        = Color(red: 0.40, green: 0.90, blue: 0.70)
    static let roseGold         = Color(red: 0.92, green: 0.60, blue: 0.55)

    // Background palette
    static let backgroundTop    = Color(red: 0.96, green: 0.95, blue: 1.00)
    static let backgroundMid    = Color(red: 0.93, green: 0.94, blue: 0.99)
    static let backgroundBottom = Color(red: 0.90, green: 0.92, blue: 0.98)

    // Card and text colours
    static let cardWhite        = Color.white
    static let darkText         = Color(red: 0.12, green: 0.10, blue: 0.20)
    static let softText         = Color(red: 0.35, green: 0.32, blue: 0.45)
    
    // Curiosity-specific
    static let curiosityBg1     = Color(red: 0.94, green: 0.98, blue: 1.00)
    static let curiosityBg2     = Color(red: 0.90, green: 0.95, blue: 0.98)
    static let curiosityBg3     = Color(red: 0.86, green: 0.92, blue: 0.96)
}

// MARK: - Category Vector Icon (No Emojis)

/// Maps category names to colourful SF Symbol-based vector icons.
/// Strictly no emoji characters – all visual elements are rendered via SF Symbols and SwiftUI shapes.
public struct CategoryVectorIcon: View {
    let category: String
    var size: CGFloat = 28
    var showBackground: Bool = true

    private var config: (icon: String, colors: [Color]) {
        switch category.lowercased() {
        case "space":
            return ("globe.americas.fill", [KidColors.cosmicPurple, KidColors.skyBlue])
        case "nature":
            return ("leaf.fill", [KidColors.tropicalTeal, KidColors.mintGreen])
        case "animals":
            return ("pawprint.fill", [KidColors.coralPink, KidColors.roseGold])
        case "human body":
            return ("heart.fill", [KidColors.coralPink, KidColors.cosmicPurpleEnd])
        case "science":
            return ("atom", [KidColors.skyBlue, KidColors.cosmicPurple])
        default: // "All"
            return ("sparkles", [KidColors.sunshineYellow, KidColors.coralPink])
        }
    }

    public var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: config.colors.map { $0.opacity(0.18) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 1.8, height: size * 1.8)
            }

            Image(systemName: config.icon)
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: config.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - Sparkle Vector Icon (replaces ✨ emoji)

/// Custom vector sparkle graphic to replace ✨ emoji.
public struct SparkleVector: View {
    var size: CGFloat = 24
    var color: Color = KidColors.sunshineYellow

    public var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - QuestionMark Bubble (replaces ❓ emoji)

/// Custom animated question-mark bubble for the card front.
public struct QuestionBubbleVector: View {
    var size: CGFloat = 48
    @State private var pulse = false

    public var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [KidColors.sunshineYellow.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)
                .scaleEffect(pulse ? 1.15 : 1.0)

            // Inner circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [KidColors.sunshineYellow, KidColors.coralPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: "questionmark")
                .font(.system(size: max(1, size * 0.5), weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Floating Decoration Background

/// Animated floating decorative shapes for kid backgrounds (no emojis).
public struct KidBackgroundView: View {
    @State private var float1 = false
    @State private var float2 = false
    @State private var float3 = false

    var variant: BackgroundVariant = .home

    public enum BackgroundVariant {
        case home, curiosity
    }

    private var bgColors: [Color] {
        switch variant {
        case .home:
            return [KidColors.backgroundTop, KidColors.backgroundMid, KidColors.backgroundBottom]
        case .curiosity:
            return [KidColors.curiosityBg1, KidColors.curiosityBg2, KidColors.curiosityBg3]
        }
    }

    public var body: some View {
        ZStack {
            // Base background gradient
            LinearGradient(colors: bgColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Soft animated ambient mesh color spheres
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                // Top-left ambient purple/blue glow
                Circle()
                    .fill(KidColors.cosmicPurple.opacity(0.12))
                    .frame(width: w * 0.7)
                    .offset(x: float1 ? -w * 0.2 : -w * 0.1, y: float2 ? -h * 0.15 : -h * 0.08)
                    .blur(radius: 60)

                // Bottom-right ambient teal/mint glow
                Circle()
                    .fill(KidColors.tropicalTeal.opacity(0.12))
                    .frame(width: w * 0.7)
                    .offset(x: float2 ? w * 0.3 : w * 0.2, y: float1 ? h * 0.4 : h * 0.5)
                    .blur(radius: 60)

                // Center coral pink accent glow
                Circle()
                    .fill(KidColors.coralPink.opacity(0.08))
                    .frame(width: w * 0.5)
                    .offset(x: float3 ? w * 0.1 : -w * 0.1, y: float3 ? h * 0.2 : h * 0.3)
                    .blur(radius: 50)

                // Floating vector elements
                // Top-left star cluster
                Image(systemName: "star.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(KidColors.sunshineYellow.opacity(0.35))
                    .offset(x: w * 0.08, y: h * 0.06)
                    .offset(y: float1 ? -12 : 12)

                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(KidColors.coralPink.opacity(0.30))
                    .offset(x: w * 0.18, y: h * 0.10)
                    .offset(y: float2 ? -8 : 8)

                // Top-right floating cloud
                HStack(spacing: -8) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.60))
                }
                .offset(x: w * 0.75, y: h * 0.05)
                .offset(x: float1 ? 10 : -10)

                // Mid-left floating sparkle
                Image(systemName: "sparkle")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(KidColors.cosmicPurple.opacity(0.30))
                    .offset(x: w * 0.06, y: h * 0.48)
                    .offset(y: float3 ? -14 : 14)

                // Mid-right floating bubble
                Circle()
                    .fill(
                        LinearGradient(colors: [KidColors.skyBlue.opacity(0.25), KidColors.tropicalTeal.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 38, height: 38)
                    .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 1))
                    .offset(x: w * 0.88, y: h * 0.42)
                    .offset(y: float2 ? -10 : 10)

                // Bottom-left floating cloud
                Image(systemName: "cloud.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.50))
                    .offset(x: w * 0.08, y: h * 0.82)
                    .offset(x: float3 ? -8 : 8)

                // Bottom-right star
                Image(systemName: "star.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(KidColors.sunshineYellow.opacity(0.30))
                    .offset(x: w * 0.84, y: h * 0.84)
                    .offset(y: float1 ? -10 : 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { float1 = true }
            withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true).delay(0.4)) { float2 = true }
            withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true).delay(0.8)) { float3 = true }
        }
    }
}

// MARK: - Gradient Badge (replaces emoji text badges)

/// Colourful gradient badge pill used for labels like "WOW!", "DAILY WONDER", etc.
public struct GradientBadge: View {
    let text: String
    let colors: [Color]
    var fontSize: CGFloat = 11

    public var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
            .shadow(color: colors.first?.opacity(0.35) ?? .clear, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Bouncy Scale Button Style

/// Press-and-release bouncy scale style for kid-friendly touch feedback.
public struct KidPressButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Card Shadow Modifier

/// Consistent rich shadow for kid cards.
public struct KidCardShadow: ViewModifier {
    var color: Color = .black.opacity(0.08)
    var radius: CGFloat = 16
    var y: CGFloat = 8

    public func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: 0, y: y)
    }
}

extension View {
    func kidCardShadow(color: Color = .black.opacity(0.08), radius: CGFloat = 16, y: CGFloat = 8) -> some View {
        modifier(KidCardShadow(color: color, radius: radius, y: y))
    }
}

// MARK: - Magic Loading Animation (replaces loading spinner)

/// A playful "magic wand" pulsing animation shown while the AI generates an answer.
public struct MagicLoadingView: View {
    @State private var pulse = false
    @State private var rotate = false

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer ring glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [KidColors.cosmicPurple.opacity(0.25), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.2 : 0.85)

                // Inner icon
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [KidColors.cosmicPurple, KidColors.skyBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotate ? 8 : -8))
            }

            Text("Thinking of something amazing...")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(KidColors.softText)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { rotate = true }
        }
    }
}

// MARK: - Category Label Text (replaces emoji in category strings)

/// Returns a kid-friendly SF Symbol name for the given category (no emoji).
public func categoryIconName(for category: String) -> String {
    switch category.lowercased() {
    case "space":      return "globe.americas.fill"
    case "nature":     return "leaf.fill"
    case "animals":    return "pawprint.fill"
    case "human body": return "heart.fill"
    case "science":    return "atom"
    default:           return "sparkles"
    }
}

/// Returns the gradient color pair for a category.
public func categoryColors(for category: String) -> [Color] {
    switch category.lowercased() {
    case "space":      return [KidColors.cosmicPurple, KidColors.skyBlue]
    case "nature":     return [KidColors.tropicalTeal, KidColors.mintGreen]
    case "animals":    return [KidColors.coralPink, KidColors.roseGold]
    case "human body": return [KidColors.coralPink, KidColors.cosmicPurpleEnd]
    case "science":    return [KidColors.skyBlue, KidColors.cosmicPurple]
    default:           return [KidColors.sunshineYellow, KidColors.coralPink]
    }
}

// MARK: - Card Theme Configuration

/// Defines the complete visual theme for a category-specific curiosity card,
/// combining custom procedural background views (grids, organic blobs, watermarks),
/// typography designs, and category color palettes.
public struct CardTheme {
    /// Category identifier key.
    public let category: String
    /// Primary gradient for card front background.
    public let frontGradient: [Color]
    /// Lighter tinted background for card back.
    public let backGradient: [Color]
    /// Border gradient colours.
    public let borderColors: [Color]
    /// Shadow accent colour.
    public let shadowColor: Color
    /// Accent colour used for buttons, action bars, etc.
    public let accentColor: Color
    /// Secondary accent for dual-tone elements.
    public let accentColorSecondary: Color
    /// Decorative SF Symbol names scattered across the card.
    public let decorIcons: [String]
    /// Themed question bubble gradient.
    public let bubbleColors: [Color]
    /// Text colour for the front side question.
    public let questionTextColor: Color
    /// Dark text colour for the answer.
    public let answerTextColor: Color
    /// Category-specific typography design (.monospaced, .rounded, .serif, .default).
    public let fontDesign: Font.Design

    /// Returns the theme for a given category.
    public static func theme(for category: String) -> CardTheme {
        switch category.lowercased() {
        case "space":
            return CardTheme(
                category: category,
                frontGradient: [
                    Color(red: 0.08, green: 0.06, blue: 0.22),
                    Color(red: 0.14, green: 0.10, blue: 0.36)
                ],
                backGradient: [
                    Color(red: 0.94, green: 0.93, blue: 1.00),
                    Color(red: 0.97, green: 0.96, blue: 1.00)
                ],
                borderColors: [KidColors.cosmicPurple.opacity(0.6), KidColors.skyBlue.opacity(0.5)],
                shadowColor: KidColors.cosmicPurple.opacity(0.30),
                accentColor: KidColors.cosmicPurple,
                accentColorSecondary: KidColors.skyBlue,
                decorIcons: ["star.fill", "moon.fill", "sparkle", "circle.fill", "globe.americas.fill"],
                bubbleColors: [KidColors.cosmicPurple, KidColors.skyBlue],
                questionTextColor: .white,
                answerTextColor: Color(red: 0.15, green: 0.12, blue: 0.30),
                fontDesign: .monospaced
            )
        case "nature":
            return CardTheme(
                category: category,
                frontGradient: [
                    Color(red: 0.04, green: 0.28, blue: 0.16),
                    Color(red: 0.08, green: 0.40, blue: 0.25)
                ],
                backGradient: [
                    Color(red: 0.94, green: 0.99, blue: 0.95),
                    Color(red: 0.97, green: 1.00, blue: 0.98)
                ],
                borderColors: [KidColors.tropicalTeal.opacity(0.6), KidColors.mintGreen.opacity(0.5)],
                shadowColor: KidColors.tropicalTeal.opacity(0.25),
                accentColor: KidColors.tropicalTeal,
                accentColorSecondary: KidColors.mintGreen,
                decorIcons: ["leaf.fill", "drop.fill", "laurel.leading", "sun.max.fill", "wind"],
                bubbleColors: [KidColors.tropicalTeal, KidColors.mintGreen],
                questionTextColor: .white,
                answerTextColor: Color(red: 0.08, green: 0.25, blue: 0.15),
                fontDesign: .rounded
            )
        case "animals":
            return CardTheme(
                category: category,
                frontGradient: [
                    Color(red: 0.42, green: 0.12, blue: 0.10),
                    Color(red: 0.52, green: 0.18, blue: 0.16)
                ],
                backGradient: [
                    Color(red: 1.00, green: 0.95, blue: 0.94),
                    Color(red: 1.00, green: 0.98, blue: 0.97)
                ],
                borderColors: [KidColors.coralPink.opacity(0.6), KidColors.roseGold.opacity(0.5)],
                shadowColor: KidColors.coralPink.opacity(0.25),
                accentColor: KidColors.coralPink,
                accentColorSecondary: KidColors.roseGold,
                decorIcons: ["pawprint.fill", "bird.fill", "hare.fill", "fish.fill", "tortoise.fill"],
                bubbleColors: [KidColors.coralPink, KidColors.sunshineYellow],
                questionTextColor: .white,
                answerTextColor: Color(red: 0.30, green: 0.12, blue: 0.08),
                fontDesign: .rounded
            )
        case "human body":
            return CardTheme(
                category: category,
                frontGradient: [
                    Color(red: 0.36, green: 0.08, blue: 0.26),
                    Color(red: 0.46, green: 0.14, blue: 0.34)
                ],
                backGradient: [
                    Color(red: 1.00, green: 0.95, blue: 0.97),
                    Color(red: 1.00, green: 0.97, blue: 0.99)
                ],
                borderColors: [KidColors.coralPink.opacity(0.6), KidColors.cosmicPurpleEnd.opacity(0.5)],
                shadowColor: KidColors.coralPink.opacity(0.20),
                accentColor: Color(red: 0.85, green: 0.25, blue: 0.50),
                accentColorSecondary: KidColors.cosmicPurpleEnd,
                decorIcons: ["heart.fill", "brain.fill", "eye.fill", "hand.raised.fill", "ear.fill"],
                bubbleColors: [Color(red: 0.85, green: 0.25, blue: 0.50), KidColors.cosmicPurpleEnd],
                questionTextColor: .white,
                answerTextColor: Color(red: 0.28, green: 0.10, blue: 0.20),
                fontDesign: .serif
            )
        case "science":
            return CardTheme(
                category: category,
                frontGradient: [
                    Color(red: 0.05, green: 0.16, blue: 0.36),
                    Color(red: 0.08, green: 0.25, blue: 0.48)
                ],
                backGradient: [
                    Color(red: 0.94, green: 0.97, blue: 1.00),
                    Color(red: 0.97, green: 0.98, blue: 1.00)
                ],
                borderColors: [KidColors.skyBlue.opacity(0.6), KidColors.cosmicPurple.opacity(0.5)],
                shadowColor: KidColors.skyBlue.opacity(0.25),
                accentColor: KidColors.skyBlue,
                accentColorSecondary: KidColors.cosmicPurple,
                decorIcons: ["atom", "bolt.fill", "flask.fill", "rays", "wand.and.stars"],
                bubbleColors: [KidColors.skyBlue, KidColors.cosmicPurple],
                questionTextColor: .white,
                answerTextColor: Color(red: 0.08, green: 0.15, blue: 0.30),
                fontDesign: .monospaced
            )
        default:
            return CardTheme(
                category: category,
                frontGradient: [KidColors.cosmicPurple, KidColors.cosmicPurpleEnd],
                backGradient: [Color(red: 0.97, green: 0.97, blue: 1.0), .white],
                borderColors: [KidColors.cosmicPurple.opacity(0.4), KidColors.skyBlue.opacity(0.4)],
                shadowColor: KidColors.cosmicPurple.opacity(0.20),
                accentColor: KidColors.cosmicPurple,
                accentColorSecondary: KidColors.skyBlue,
                decorIcons: ["sparkle", "star.fill", "circle.fill", "heart.fill", "moon.fill"],
                bubbleColors: [KidColors.sunshineYellow, KidColors.coralPink],
                questionTextColor: .white,
                answerTextColor: KidColors.darkText,
                fontDesign: .rounded
            )
        }
    }

    /// Procedural custom background view overlay (grid patterns, organic blobs, classic textures, geometric watermarks).
    @ViewBuilder
    public var customPatternOverlay: some View {
        switch category.lowercased() {
        case "space":
            // Dark Terminal / Blueprint Star Grid look
            GeometryReader { geo in
                Path { path in
                    let step: CGFloat = 24
                    for x in stride(from: 0, to: geo.size.width, by: step) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    for y in stride(from: 0, to: geo.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(KidColors.skyBlue.opacity(0.12), lineWidth: 1)
            }

        case "nature":
            // Organic soft look with floating leaf blobs
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.08))
                        .frame(width: geo.size.width * 0.7)
                        .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)

                    Circle()
                        .fill(KidColors.mintGreen.opacity(0.06))
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.5)
                }
            }

        case "animals":
            // Vibrant organic look with layered colorful circles
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(KidColors.coralPink.opacity(0.08))
                        .frame(width: geo.size.width * 0.65)
                        .offset(x: geo.size.width * 0.35, y: -geo.size.height * 0.1)

                    Circle()
                        .fill(KidColors.sunshineYellow.opacity(0.06))
                        .frame(width: geo.size.width * 0.55)
                        .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.6)
                }
            }

        case "human body":
            // Warm Paper / Soft anatomical organic radial glow
            GeometryReader { geo in
                ZStack {
                    RadialGradient(
                        colors: [Color(red: 0.98, green: 0.85, blue: 0.90).opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.8
                    )
                }
            }

        case "science":
            // Lab Blueprint geometric watermark grid look
            GeometryReader { geo in
                ZStack {
                    Path { path in
                        let step: CGFloat = 20
                        for x in stride(from: 0, to: geo.size.width, by: step) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geo.size.height))
                        }
                        for y in stride(from: 0, to: geo.size.height, by: step) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                    }
                    .stroke(KidColors.skyBlue.opacity(0.10), lineWidth: 1)

                    // Geometric watermark triangle
                    Path { path in
                        path.move(to: CGPoint(x: geo.size.width * 0.6, y: 0))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.5))
                        path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    }
                    .fill(KidColors.skyBlue.opacity(0.08))
                }
            }

        default:
            GeometryReader { geo in
                Circle()
                    .fill(KidColors.cosmicPurple.opacity(0.06))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: geo.size.width * 0.2, y: -geo.size.height * 0.1)
            }
        }
    }

    /// Full screen application background view tailored to the current category theme.
    @ViewBuilder
    public var mainScreenBackground: some View {
        switch category.lowercased() {
        case "space":
            ZStack {
                Color(red: 0.05, green: 0.04, blue: 0.12).ignoresSafeArea()
                RadialGradient(colors: [KidColors.cosmicPurple.opacity(0.20), .clear], center: .topTrailing, startRadius: 0, endRadius: 600)
                RadialGradient(colors: [KidColors.skyBlue.opacity(0.15), .clear], center: .bottomLeading, startRadius: 0, endRadius: 600)
            }
        case "nature":
            ZStack {
                Color(red: 0.94, green: 0.98, blue: 0.94).ignoresSafeArea()
                RadialGradient(colors: [KidColors.tropicalTeal.opacity(0.18), .clear], center: .topLeading, startRadius: 0, endRadius: 500)
                RadialGradient(colors: [KidColors.mintGreen.opacity(0.15), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 500)
            }
        case "animals":
            ZStack {
                Color(red: 0.99, green: 0.95, blue: 0.94).ignoresSafeArea()
                RadialGradient(colors: [KidColors.coralPink.opacity(0.16), .clear], center: .topLeading, startRadius: 0, endRadius: 500)
                RadialGradient(colors: [KidColors.sunshineYellow.opacity(0.12), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 500)
            }
        case "human body":
            ZStack {
                Color(red: 0.98, green: 0.95, blue: 0.96).ignoresSafeArea()
                RadialGradient(colors: [Color(red: 0.85, green: 0.25, blue: 0.50).opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: 700)
            }
        case "science":
            ZStack {
                Color(red: 0.94, green: 0.96, blue: 0.99).ignoresSafeArea()
                RadialGradient(colors: [KidColors.skyBlue.opacity(0.18), .clear], center: .topLeading, startRadius: 0, endRadius: 600)
            }
        default:
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98).ignoresSafeArea()
                GeometryReader { proxy in
                    ZStack {
                        Circle().fill(KidColors.skyBlue.opacity(0.10)).frame(width: proxy.size.width * 0.8)
                            .offset(x: -proxy.size.width * 0.2, y: -proxy.size.height * 0.3).blur(radius: 60)
                        Circle().fill(KidColors.cosmicPurple.opacity(0.10)).frame(width: proxy.size.width * 0.8)
                            .offset(x: proxy.size.width * 0.2, y: proxy.size.height * 0.2).blur(radius: 60)
                    }
                }
            }
        }
    }
}

// MARK: - Thematic Card Decoration Overlay

/// Renders floating, animated, semi-transparent SF Symbol decorations
/// unique to the card's category. Placed as an overlay on both card sides.
public struct ThematicCardDecoration: View {
    let theme: CardTheme
    let isBackSide: Bool
    @State private var drift1 = false
    @State private var drift2 = false
    @State private var drift3 = false

    private var baseOpacity: Double { isBackSide ? 0.08 : 0.12 }
    private var iconColor: Color { isBackSide ? theme.accentColor : .white }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Icon 0 — top-right area
            Image(systemName: theme.decorIcons[0])
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(iconColor.opacity(baseOpacity + 0.06))
                .offset(x: w * 0.78, y: h * 0.08)
                .offset(y: drift1 ? -6 : 6)

            // Icon 1 — top-left
            Image(systemName: theme.decorIcons[1])
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(iconColor.opacity(baseOpacity + 0.04))
                .offset(x: w * 0.12, y: h * 0.14)
                .offset(x: drift2 ? 5 : -5)

            // Icon 2 — mid-right
            Image(systemName: theme.decorIcons[2])
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(iconColor.opacity(baseOpacity))
                .offset(x: w * 0.85, y: h * 0.45)
                .offset(y: drift3 ? -8 : 8)

            // Icon 3 — bottom-left
            Image(systemName: theme.decorIcons[3])
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconColor.opacity(baseOpacity + 0.03))
                .offset(x: w * 0.08, y: h * 0.75)
                .offset(y: drift1 ? -4 : 4)

            // Icon 4 — bottom-right
            Image(systemName: theme.decorIcons[4])
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor.opacity(baseOpacity + 0.05))
                .offset(x: w * 0.72, y: h * 0.82)
                .offset(x: drift2 ? 4 : -4)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) { drift1 = true }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(0.3)) { drift2 = true }
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true).delay(0.7)) { drift3 = true }
        }
    }
}

// MARK: - Themed Question Bubble

/// Category-aware animated question mark bubble that uses the theme's accent colours.
public struct ThemedQuestionBubble: View {
    let theme: CardTheme
    var size: CGFloat = 56
    @State private var pulse = false

    public var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.bubbleColors.first?.opacity(0.35) ?? .clear, .clear],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.95
                    )
                )
                .frame(width: size * 1.7, height: size * 1.7)
                .scaleEffect(pulse ? 1.15 : 1.0)

            // Inner filled circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: theme.bubbleColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: "questionmark")
                .font(.system(size: max(1, size * 0.48), weight: .black, design: theme.fontDesign))
                .foregroundStyle(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Themed Magic Loading View

/// Category-aware magic loading animation that matches the card theme.
public struct ThemedMagicLoadingView: View {
    let theme: CardTheme
    @State private var pulse = false
    @State private var rotate = false

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer ring glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.accentColor.opacity(0.25), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.2 : 0.85)

                // Themed icon
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.accentColor, theme.accentColorSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotate ? 8 : -8))
            }

            Text("Thinking of something amazing...")
                .font(.system(size: 16, weight: .bold, design: theme.fontDesign))
                .foregroundStyle(theme.answerTextColor.opacity(0.6))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { rotate = true }
        }
    }
}


