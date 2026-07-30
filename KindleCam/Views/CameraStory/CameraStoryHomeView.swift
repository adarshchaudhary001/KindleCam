//
//  CameraStoryHomeView.swift
//  KindleCam
//
//  Placeholder View for Camera Story module.
//

import SwiftUI
import SwiftData

public struct CameraStoryHomeView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.93, blue: 1.0), Color(red: 0.9, green: 0.85, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header badge
                HStack {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Camera Story")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.15, blue: 0.6))
                        
                        Text("Vision + Foundation Models")
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
                            .fill(Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "sparkles.tv.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                    }
                    
                    Text("Point & Capture Story")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.2, green: 0.1, blue: 0.4))
                    
                    Text("Capture objects around you and turn them into magical interactive stories!")
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
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text("Open Camera (Coming Soon)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.48, green: 0.24, blue: 0.93), Color(red: 0.58, green: 0.34, blue: 0.98)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Camera Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CameraStoryHomeView()
    }
}
