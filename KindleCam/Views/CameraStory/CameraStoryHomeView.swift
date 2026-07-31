//
//  CameraStoryHomeView.swift
//  KindleCam
//
//  Entry point for the Camera Story module.
//  Shows saved stories and a prominent "Start New Adventure" button.
//  Hosts the full story flow: Camera → Adventure → Completion.
//

import SwiftUI
import SwiftData
import PhotosUI

public struct CameraStoryHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CameraStory.creationDate, order: .reverse) private var savedStories: [CameraStory]
    @State private var viewModel = CameraStoryViewModel()
    @State private var showCamera: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.96, green: 0.95, blue: 1.0), Color(red: 0.9, green: 0.85, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content based on ViewModel phase
            switch viewModel.phase {
            case .idle:
                homeContent
            case .capturing, .detectingObjects, .generatingStory:
                CameraCaptureView(viewModel: viewModel)
            case .reviewing:
                ImageAnnotationView(viewModel: viewModel)
            case .adventure:
                StoryAdventureView(viewModel: viewModel)
            case .completed:
                StoryCompletionView(viewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden(viewModel.phase != .idle)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            // When reset back to idle, ensure model context is still set
            if newPhase == .idle {
                viewModel.setModelContext(modelContext)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.startReview(with: image)
                }
                selectedPhotoItem = nil
            }
        }
    }
    
    // MARK: - Home Content (Idle State)
    
    private var homeContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Camera Story")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                        
                        Text("Point · Capture · Play!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Hero Card — Start New Adventure
                Button(action: {
                    viewModel.phase = .capturing
                }) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.15))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                        }
                        
                        Text("Start New Adventure! 📸")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.2, green: 0.1, blue: 0.4))
                        
                        Text("Point your camera at something and create a magical story!")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .bold))
                            Text("Let's Go!")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
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
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
                    )
                }
                .buttonStyle(CardPressStyle())
                .padding(.horizontal)
                
                // Option: Pick from Photo Library
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 18, weight: .bold))
                        Text("Upload Image from Gallery 🖼️")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.4), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
                }
                .padding(.horizontal)
                
                // Saved Stories Section
                if !savedStories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Stories 📚")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                            .padding(.horizontal)
                        
                        ForEach(savedStories) { story in
                            savedStoryCard(story)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Saved Story Card
    
    private func savedStoryCard(_ story: CameraStory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📖")
                    .font(.system(size: 20))
                
                Text(story.title.isEmpty ? "Untitled Story" : story.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                
                Spacer()
                
                Text(story.creationDate, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            
            // Object badges
            if !story.capturedObjects.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(story.capturedObjects) { obj in
                            Text(obj.label)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Task completion
            let completedCount = story.tasks.filter { $0.completed }.count
            let totalCount = story.tasks.count
            HStack(spacing: 4) {
                Text("⭐")
                    .font(.system(size: 12))
                Text("\(completedCount)/\(totalCount) tasks completed")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Card Press Button Style

private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        CameraStoryHomeView()
    }
    .modelContainer(AppModelContainer.previewContainer())
}
