//
//  StoryAdventureView.swift
//  KindleCam
//
//  Primary adventure UI showing the generated story, progress bar,
//  and hosting the interactive task views. The child progresses through
//  tasks to advance the story.
//

import SwiftUI

public struct StoryAdventureView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 1.0),
                    Color(red: 0.93, green: 0.91, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Header
                progressHeader
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Story Card
                        storyCard
                        
                        // Current Task
                        if let task = viewModel.currentTask {
                            // Story segment leading into this task
                            storySegmentBubble(task.storySegment)
                            
                            // Interactive task
                            TaskInteractiveView(viewModel: viewModel, task: task)
                                .padding(.horizontal)
                        }
                        
                        // Feedback Banner
                        if viewModel.showFeedback {
                            feedbackBanner
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Bottom Bar
                bottomBar
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                }
                
                Spacer()
                
                // Step indicators
                HStack(spacing: 6) {
                    stepBadge(number: 1, label: "Capture", isActive: false, isComplete: true)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                    
                    stepBadge(number: 2, label: "Story Time", isActive: true, isComplete: false)
                }
                
                Spacer()
                
                // Speaker button (placeholder for audio)
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.5))
            }
            .padding(.horizontal)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.15))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.48, green: 0.24, blue: 0.93))
                        .frame(width: geometry.size.width * viewModel.progress, height: 6)
                        .animation(.spring(response: 0.4), value: viewModel.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.9))
    }
    
    // MARK: - Story Card
    
    private var storyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📖")
                    .font(.system(size: 24))
                Text(viewModel.storyTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
            }
            
            Text(viewModel.storyText)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 0.2, green: 0.1, blue: 0.4))
                .lineSpacing(4)
            
            // Detected objects as sticker badges
            if !viewModel.detectedObjects.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.detectedObjects) { obj in
                            Text(obj.label)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.48, green: 0.24, blue: 0.93))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Story Segment Bubble
    
    private func storySegmentBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💬")
                .font(.system(size: 24))
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.95, green: 0.93, blue: 1.0))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Feedback Banner
    
    private var feedbackBanner: some View {
        HStack(spacing: 10) {
            Text(viewModel.isCorrectFeedback ? "🎉" : "💪")
                .font(.system(size: 28))
            
            Text(viewModel.feedbackMessage)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.isCorrectFeedback
                                 ? Color(red: 0.1, green: 0.6, blue: 0.3)
                                 : Color(red: 0.9, green: 0.5, blue: 0.1))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(viewModel.isCorrectFeedback
                      ? Color(red: 0.85, green: 1.0, blue: 0.9)
                      : Color(red: 1.0, green: 0.95, blue: 0.85))
        )
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4), value: viewModel.showFeedback)
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                if viewModel.showFeedback && viewModel.isCorrectFeedback {
                    Button(action: {
                        withAnimation {
                            viewModel.advanceToNextTask()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.allTasksCompleted ? "Finish! 🏆" : "Next →")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.48, green: 0.24, blue: 0.93))
                        )
                    }
                } else {
                    Text(viewModel.feedbackMessage.isEmpty
                         ? "Complete the task to continue! ⭐"
                         : viewModel.feedbackMessage)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color.white)
        }
    }
    
    // MARK: - Step Badge
    
    private func stepBadge(number: Int, label: String, isActive: Bool, isComplete: Bool) -> some View {
        HStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isComplete
                          ? Color(red: 0.1, green: 0.7, blue: 0.4)
                          : isActive
                          ? Color(red: 0.48, green: 0.24, blue: 0.93)
                          : Color.gray.opacity(0.3))
                    .frame(width: 22, height: 22)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isActive ? Color(red: 0.3, green: 0.15, blue: 0.6) : Color.secondary)
        }
    }
}
