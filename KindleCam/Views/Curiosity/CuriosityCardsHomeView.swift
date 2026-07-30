//
//  CuriosityCardsHomeView.swift
//  KindleCam
//
//  Placeholder View for Curiosity Questions / Cards module.
//

import SwiftUI
import SwiftData

public struct CuriosityCardsHomeView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.9, green: 0.98, blue: 0.94), Color(red: 0.82, green: 0.95, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header badge
                HStack {
                    Image(systemName: "lightbulb.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Curiosity Cards")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.02, green: 0.45, blue: 0.3))
                        
                        Text("Interactive Q&A Cards")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Placeholder illustration card
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "questionmark.bubble.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
                    }
                    
                    Text("Explore & Learn")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.01, green: 0.3, blue: 0.2))
                    
                    Text("Discover fun questions, answers, and wonder facts about nature, science, animals, and more!")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 32)
                }
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Action placeholder button
                Button(action: {
                    // Feature coming soon
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                        Text("Explore Cards (Coming Soon)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.06, green: 0.72, blue: 0.5), Color(red: 0.1, green: 0.8, blue: 0.58)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Curiosity Cards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CuriosityCardsHomeView()
    }
}
