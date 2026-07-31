//
//  CuriosityQuestionDetailView.swift
//  KindleCam
//
//  Dedicated Question Detail screen displaying the curiosity question prominently,
//  generating an AI answer via Foundation Models, and marking answered status in SwiftData.
//

import SwiftUI

public struct CuriosityQuestionDetailView: View {
    let question: CuriosityQuestion
    @Bindable var viewModel: CuriosityCardsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var answerText: String = ""
    @State private var isLoadingAnswer: Bool = true
    @State private var isFavorite: Bool = false
    
    public init(question: CuriosityQuestion, viewModel: CuriosityCardsViewModel) {
        self.question = question
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.98, blue: 0.95),
                    Color(red: 0.85, green: 0.95, blue: 0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Top Navigation Bar
                headerBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Category Badge
                        categoryBadge
                        
                        // Main Question Card
                        questionCard
                        
                        // AI Answer Card
                        aiAnswerCard
                        
                        // Interactive Actions Card (Favorite & Audio)
                        actionsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isFavorite = viewModel.isFavorite(question.id)
            loadAnswer()
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28))
                    Text("Back")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.04, green: 0.6, blue: 0.4))
            }
            
            Spacer()
            
            Text("Curiosity Answer")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.02, green: 0.45, blue: 0.3))
            
            Spacer()
            
            // Favorite Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isFavorite.toggle()
                    viewModel.toggleFavorite(question.id)
                }
            }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 24))
                    .foregroundStyle(isFavorite ? Color(red: 1.0, green: 0.75, blue: 0.1) : Color.gray.opacity(0.4))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.8))
    }
    
    // MARK: - Category Badge
    
    private var categoryBadge: some View {
        HStack(spacing: 6) {
            Text(categoryEmoji(for: question.category))
                .font(.system(size: 16))
            Text(question.category.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.04, green: 0.6, blue: 0.4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.15))
        .clipShape(Capsule())
    }
    
    // MARK: - Question Card
    
    private var questionCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Text("❓")
                    .font(.system(size: 40))
            }
            
            Text(question.question)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.01, green: 0.3, blue: 0.2))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - AI Answer Card
    
    private var aiAnswerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
                    
                    Text("AI Answer")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.02, green: 0.45, blue: 0.3))
                }
                
                Spacer()
                
                Text("Foundation Models")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if isLoadingAnswer {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(red: 0.06, green: 0.72, blue: 0.5))
                    
                    Text("Asking Apple AI... ✨")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(answerText)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.1, green: 0.25, blue: 0.18))
                    .lineSpacing(6)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Actions Card
    
    private var actionsCard: some View {
        HStack(spacing: 16) {
            // Speaker readout placeholder
            Button(action: {
                // Audio speech action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Read Aloud")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.06, green: 0.72, blue: 0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 0.06, green: 0.72, blue: 0.5).opacity(0.12))
                )
            }
            
            // Mark Answered indicator
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 0.1, green: 0.7, blue: 0.4))
                Text("Answered!")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.1, green: 0.6, blue: 0.3))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.1, green: 0.7, blue: 0.4).opacity(0.15))
            )
        }
    }
    
    // MARK: - Answer Loading & Mark Answered
    
    private func loadAnswer() {
        Task {
            let fetched = await viewModel.fetchAnswer(for: question)
            withAnimation(.easeInOut(duration: 0.3)) {
                answerText = fetched
                isLoadingAnswer = false
            }
            // Mark as answered in SwiftData
            viewModel.markAnswered(question.id)
        }
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
