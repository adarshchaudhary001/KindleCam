//
//  TaskInteractiveView.swift
//  KindleCam
//
//  Host view that routes to the appropriate interactive task UI based on TaskType.
//  Contains QuizTaskView, CountTaskView, and TapTaskView as sub-views.
//

import SwiftUI

// MARK: - Task Router

/// Routes to the correct interactive task view based on the current task type.
public struct TaskInteractiveView: View {
    @Bindable var viewModel: CameraStoryViewModel
    let task: StoryTask
    
    public init(viewModel: CameraStoryViewModel, task: StoryTask) {
        self.viewModel = viewModel
        self.task = task
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            switch task.taskType {
            case .quizQuestion:
                QuizTaskView(viewModel: viewModel, task: task)
            case .countObjects:
                CountTaskView(viewModel: viewModel, task: task)
            case .tapObjects:
                TapTaskView(viewModel: viewModel, task: task)
            default:
                // Fallback for unsupported task types
                QuizTaskView(viewModel: viewModel, task: task)
            }
        }
    }
}

// MARK: - Quiz Task View

/// Multiple-choice quiz with colorful rounded option buttons.
struct QuizTaskView: View {
    @Bindable var viewModel: CameraStoryViewModel
    let task: StoryTask
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            // Question prompt
            HStack(spacing: 8) {
                Text("❓")
                    .font(.system(size: 28))
                Text(task.taskDescription)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.1))
            )
            
            // Options
            if let payload = task.payload, case .quiz(let options, _) = payload {
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        Button(action: {
                            selectedIndex = index
                            viewModel.submitQuizAnswer(selectedIndex: index)
                        }) {
                            HStack {
                                quizEmoji(for: index)
                                
                                Text(option)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(selectedIndex == index ? .white : Color(red: 0.3, green: 0.15, blue: 0.6))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(selectedIndex == index
                                          ? Color(red: 0.48, green: 0.24, blue: 0.93)
                                          : Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            )
                        }
                        .disabled(viewModel.showFeedback && viewModel.isCorrectFeedback)
                    }
                }
            }
        }
        .onChange(of: viewModel.currentTaskIndex) { _, _ in
            selectedIndex = nil
        }
    }
    
    @ViewBuilder
    private func quizEmoji(for index: Int) -> some View {
        let emojis = ["🔴", "🟡", "🟢", "🔵"]
        Text(emojis[index % emojis.count])
            .font(.system(size: 24))
    }
}

// MARK: - Count Task View

/// Interactive counter where the child selects a number.
struct CountTaskView: View {
    @Bindable var viewModel: CameraStoryViewModel
    let task: StoryTask
    @State private var selectedCount: Int = 1
    @State private var hasSubmitted: Bool = false
    
    private var objectLabel: String {
        if let payload = task.payload, case .count(_, let label) = payload {
            return label
        }
        return "items"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Prompt
            HStack(spacing: 8) {
                Text("🔢")
                    .font(.system(size: 28))
                Text(task.taskDescription)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.1))
            )
            
            // Visual object display
            HStack(spacing: 8) {
                if let payload = task.payload, case .count(let correctCount, _) = payload {
                    ForEach(0..<correctCount, id: \.self) { _ in
                        Text("⭐")
                            .font(.system(size: 36))
                    }
                }
            }
            .padding()
            
            // Number selector
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { number in
                    Button(action: {
                        selectedCount = number
                    }) {
                        Text("\(number)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedCount == number ? .white : Color(red: 0.3, green: 0.15, blue: 0.6))
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(selectedCount == number
                                          ? Color(red: 0.48, green: 0.24, blue: 0.93)
                                          : Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                    }
                    .disabled(hasSubmitted && viewModel.isCorrectFeedback)
                }
            }
            
            // Submit button
            if !hasSubmitted || !viewModel.isCorrectFeedback {
                Button(action: {
                    hasSubmitted = true
                    viewModel.submitCountAnswer(count: selectedCount)
                }) {
                    Text("That's my answer! ✅")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.48, green: 0.24, blue: 0.93))
                        )
                }
            }
        }
        .onChange(of: viewModel.currentTaskIndex) { _, _ in
            selectedCount = 1
            hasSubmitted = false
        }
    }
}

// MARK: - Tap Task View

/// Interactive tapping game where the child taps targets on screen.
struct TapTaskView: View {
    @Bindable var viewModel: CameraStoryViewModel
    let task: StoryTask
    @State private var tappedItems: Set<Int> = []
    @State private var targetPositions: [CGPoint] = []
    @State private var containerSize: CGSize = .zero
    
    private var targetCount: Int {
        if let payload = task.payload, case .tap(let count, _) = payload {
            return count
        }
        return 4
    }
    
    private var objectLabel: String {
        if let payload = task.payload, case .tap(_, let label) = payload {
            return label
        }
        return "stars"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Prompt
            HStack(spacing: 8) {
                Text("👆")
                    .font(.system(size: 28))
                Text(task.taskDescription)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.1))
            )
            
            // Progress indicator
            Text("Tapped: \(tappedItems.count) / \(targetCount)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondary)
            
            // Tap area
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.96, green: 0.95, blue: 1.0), Color(red: 0.92, green: 0.90, blue: 0.98)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    ForEach(0..<targetCount, id: \.self) { index in
                        if !tappedItems.contains(index) {
                            Button(action: {
                                _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    tappedItems.insert(index)
                                }
                                // Auto-submit when all targets are tapped
                                if tappedItems.count >= targetCount {
                                    viewModel.submitTapCompletion(tappedCount: tappedItems.count)
                                }
                            }) {
                                Text("⭐")
                                    .font(.system(size: 40))
                                    .shadow(color: Color.yellow.opacity(0.5), radius: 6, x: 0, y: 2)
                            }
                            .position(targetPosition(for: index, in: geometry.size))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .onAppear {
                    containerSize = geometry.size
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .onChange(of: viewModel.currentTaskIndex) { _, _ in
            tappedItems = []
        }
    }
    
    /// Generate a deterministic position for each target within the tap area.
    private func targetPosition(for index: Int, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 40
        let availableWidth = max(size.width - padding * 2, 1)
        let availableHeight = max(size.height - padding * 2, 1)
        
        // Use deterministic but visually distributed positions
        let positions: [(CGFloat, CGFloat)] = [
            (0.2, 0.3), (0.7, 0.2), (0.4, 0.7), (0.8, 0.6),
            (0.15, 0.6), (0.6, 0.45), (0.35, 0.4), (0.85, 0.35)
        ]
        
        let pos = positions[index % positions.count]
        return CGPoint(
            x: padding + pos.0 * availableWidth,
            y: padding + pos.1 * availableHeight
        )
    }
}
