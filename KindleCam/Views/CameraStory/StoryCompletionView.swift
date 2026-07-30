//
//  StoryCompletionView.swift
//  KindleCam
//
//  Celebratory end screen shown when the child completes all tasks in a Camera Story.
//  Features confetti-like star animations, achievement badge, and options to
//  start a new story or return home.
//

import SwiftUI

public struct StoryCompletionView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showStars: Bool = false
    @State private var badgeScale: CGFloat = 0.1
    
    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 0.9, green: 0.85, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated celebration stars
            if showStars {
                celebrationStars
            }
            
            // Main content
            VStack(spacing: 32) {
                Spacer()
                
                // Achievement badge
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.1).opacity(0.4), radius: 20, x: 0, y: 8)
                        
                        Text("🏆")
                            .font(.system(size: 60))
                    }
                    .scaleEffect(badgeScale)
                    
                    Text("Amazing Job!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.48, green: 0.24, blue: 0.93), Color(red: 0.8, green: 0.2, blue: 0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("You completed the adventure!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                
                // Story recap card
                VStack(spacing: 12) {
                    Text("📖 \(viewModel.storyTitle)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                    
                    HStack(spacing: 16) {
                        statBadge(value: "\(viewModel.tasks.count)", label: "Tasks", emoji: "⭐")
                        statBadge(value: "\(viewModel.detectedObjects.count)", label: "Objects", emoji: "🔍")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.reset()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("New Adventure!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.48, green: 0.24, blue: 0.93), Color(red: 0.58, green: 0.34, blue: 0.98)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    
                    Button(action: {
                        viewModel.reset()
                        dismiss()
                    }) {
                        Text("Go Home 🏠")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
                badgeScale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.5).delay(0.4)) {
                showStars = true
            }
        }
    }
    
    // MARK: - Stat Badge
    
    private func statBadge(value: String, label: String, emoji: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 24))
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - Celebration Stars
    
    private var celebrationStars: some View {
        GeometryReader { geometry in
            ForEach(0..<12, id: \.self) { index in
                Text(["⭐", "🌟", "✨", "💫"][index % 4])
                    .font(.system(size: CGFloat.random(in: 16...32)))
                    .position(
                        x: CGFloat.random(in: 20...geometry.size.width - 20),
                        y: CGFloat.random(in: 20...geometry.size.height - 20)
                    )
                    .opacity(0.7)
            }
        }
        .allowsHitTesting(false)
    }
}
