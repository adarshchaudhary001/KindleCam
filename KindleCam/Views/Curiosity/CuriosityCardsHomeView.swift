//
//  CuriosityCardsHomeView.swift
//  KindleCam
//
//  Main entry View for the Curiosity Cards feature.
//  Displays the deterministic Daily Wonder hero banner, category filter pills,
//  and the Curious Minds question list with answered checkmark indicators.
//

import SwiftUI
import SwiftData

public struct CuriosityCardsHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CuriosityCardsViewModel()
    
    private let categories = ["All", "Space", "Nature", "Animals", "Human Body", "Science"]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.98, blue: 0.95),
                    Color(red: 0.88, green: 0.96, blue: 0.92),
                    Color(red: 0.84, green: 0.94, blue: 0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Daily Wonder Hero Card
                    if let dailyWonder = viewModel.dailyWonderQuestion {
                        dailyWonderCard(dailyWonder)
                    }
                    
                    // Category Filter Pills
                    categoryPillsSection
                    
                    // Curious Minds Question List
                    curiousMindsSection
                }
                .padding(.horizontal, 20)
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
        HStack {
            Image(systemName: "lightbulb.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Curiosity Cards")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.02, green: 0.45, blue: 0.3))
                    Text("✨")
                        .font(.system(size: 22))
                }
                
                Text("Explore & Wonder Everyday!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: - Daily Wonder Hero Card
    
    private func dailyWonderCard(_ question: CuriosityQuestion) -> some View {
        NavigationLink(destination: CuriosityQuestionDetailView(question: question, viewModel: viewModel)) {
            VStack(alignment: .leading, spacing: 14) {
                // Top Row: Badge + Sparkle
                HStack {
                    HStack(spacing: 6) {
                        Text("🌟")
                            .font(.system(size: 16))
                        Text("DAILY WONDER")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color(red: 1.0, green: 0.75, blue: 0.1))
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.1).opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                    
                    if viewModel.isAnswered(question.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Answered")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Capsule())
                    }
                }
                
                // Question Text
                Text(question.question)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                // Action Indicator
                HStack {
                    Text("Discover Today's Wonder")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.72, blue: 0.5),
                        Color(red: 0.1, green: 0.8, blue: 0.58)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.35), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(CardPressStyle())
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
                            Text(categoryEmoji(for: cat))
                                .font(.system(size: 14))
                            Text(cat)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(viewModel.selectedCategory == cat ? .white : Color(red: 0.02, green: 0.45, blue: 0.3))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == cat
                                      ? Color(red: 0.06, green: 0.72, blue: 0.5)
                                      : Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Curious Minds Section
    
    private var curiousMindsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Curious Minds 💡")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.02, green: 0.45, blue: 0.3))
                
                Spacer()
                
                Text("\(viewModel.answeredQuestionIds.count) Answered")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            
            if viewModel.curiosityQuestions.isEmpty {
                VStack(spacing: 12) {
                    Text("🎉")
                        .font(.system(size: 40))
                    Text("You've answered all questions in this category!")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
            } else {
                ForEach(viewModel.curiosityQuestions) { question in
                    NavigationLink(destination: CuriosityQuestionDetailView(question: question, viewModel: viewModel)) {
                        questionCardRow(question)
                    }
                    .buttonStyle(CardPressStyle())
                }
            }
        }
    }
    
    // MARK: - Question Card Row
    
    private func questionCardRow(_ question: CuriosityQuestion) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Text(categoryEmoji(for: question.category))
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(question.question)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.01, green: 0.3, blue: 0.2))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    Text(question.category)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
                    
                    if viewModel.isFavorite(question.id) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 1.0, green: 0.75, blue: 0.1))
                    }
                }
            }
            
            Spacer()
            
            // Answered checkmark badge
            if viewModel.isAnswered(question.id) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.1, green: 0.7, blue: 0.4))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.gray.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
    
    private func categoryEmoji(for category: String) -> String {
        switch category.lowercased() {
        case "space": return "🚀"
        case "nature": return "🌿"
        case "animals": return "🐶"
        case "human body": return "🧠"
        case "science": return "🔬"
        default: return "✨"
        }
    }
}

// MARK: - Card Press Style

private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        CuriosityCardsHomeView()
    }
    .modelContainer(AppModelContainer.previewContainer())
}
