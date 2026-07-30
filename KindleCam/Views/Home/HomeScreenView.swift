//
//  HomeScreenView.swift
//  KindleCam
//
//  Main Home Screen View providing access to the 3 core functionalities:
//  1. Camera Story (Vision + Foundation Models)
//  2. Creative Drawing (Canvas & Templates)
//  3. Curiosity Cards (Interactive Q&A)
//

import SwiftUI

public struct HomeScreenView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.95, blue: 1.0),
                        Color(red: 0.93, green: 0.94, blue: 0.99),
                        Color(red: 0.90, green: 0.92, blue: 0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Decorative Stars and Clouds in Background
                VStack {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.4))
                            .padding(.leading, 30)
                            .padding(.top, 20)
                        Spacer()
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding(.trailing, 25)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.3))
                            .padding(.leading, 20)
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.7).opacity(0.4))
                            .padding(.trailing, 40)
                    }
                    .padding(.bottom, 60)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // App Header
                        VStack(spacing: 8) {
                            HStack {
                                Text("KindleCam")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(red: 0.48, green: 0.24, blue: 0.93), Color(red: 0.8, green: 0.2, blue: 0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("✨")
                                    .font(.system(size: 28))
                            }
                            
                            Text("What would you like to explore today?")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        // Feature 1: Camera Story
                        NavigationLink(destination: CameraStoryHomeView()) {
                            FeatureCard(
                                title: "Camera Story",
                                subtitle: "Point camera at objects to create magical interactive stories!",
                                iconName: "camera.fill",
                                badgeText: "WOW!",
                                badgeColor: Color(red: 1.0, green: 0.4, blue: 0.6),
                                gradientColors: [
                                    Color(red: 0.48, green: 0.24, blue: 0.93),
                                    Color(red: 0.62, green: 0.36, blue: 0.98)
                                ],
                                iconBackgroundColor: Color.white.opacity(0.25),
                                buttonText: "Start Story Adventure"
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        // Feature 2: Creative Drawing
                        NavigationLink(destination: CreativeDrawingHomeView()) {
                            FeatureCard(
                                title: "Creative Drawing",
                                subtitle: "Paint on digital canvases & color fun artwork templates!",
                                iconName: "paintpalette.fill",
                                badgeText: "CREATIVE!",
                                badgeColor: Color(red: 0.98, green: 0.65, blue: 0.1),
                                gradientColors: [
                                    Color(red: 1.0, green: 0.35, blue: 0.35),
                                    Color(red: 1.0, green: 0.52, blue: 0.38)
                                ],
                                iconBackgroundColor: Color.white.opacity(0.25),
                                buttonText: "Start Drawing"
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        // Feature 3: Curiosity Cards
                        NavigationLink(destination: CuriosityCardsHomeView()) {
                            FeatureCard(
                                title: "Curiosity Cards",
                                subtitle: "Discover fun Q&A cards, science facts & wonder questions!",
                                iconName: "lightbulb.fill",
                                badgeText: "DISCOVER!",
                                badgeColor: Color(red: 0.3, green: 0.7, blue: 1.0),
                                gradientColors: [
                                    Color(red: 0.06, green: 0.72, blue: 0.5),
                                    Color(red: 0.1, green: 0.8, blue: 0.58)
                                ],
                                iconBackgroundColor: Color.white.opacity(0.25),
                                buttonText: "Explore Questions"
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Feature Card Component

private struct FeatureCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let badgeText: String
    let badgeColor: Color
    let gradientColors: [Color]
    let iconBackgroundColor: Color
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: Icon + Title + Badge
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 4)
                
                Spacer()
                
                // Sticker Badge
                Text(badgeText)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badgeColor)
                    .clipShape(Capsule())
                    .shadow(color: badgeColor.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            
            // Bottom Action Indicator
            HStack {
                Text(buttonText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .clipShape(Capsule())
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: gradientColors.first?.opacity(0.35) ?? Color.clear, radius: 14, x: 0, y: 8)
    }
}

// MARK: - Custom Card Button Style for Touch Micro-Animations

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HomeScreenView()
}
