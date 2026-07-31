//
//  CreativeDrawingHomeView.swift
//  KindleCam
//
//  Placeholder View for Creative Drawing module.
//

import SwiftUI
import SwiftData

public struct CreativeDrawingHomeView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.94, blue: 0.94), Color(red: 1.0, green: 0.88, blue: 0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header badge
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Creative Drawing")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.7, green: 0.15, blue: 0.15))
                        
                        Text("Canvas & Templates")
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
                            .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "pencil.tip.crop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35))
                    }
                    
                    Text("Express Your Creativity")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.5, green: 0.1, blue: 0.1))
                    
                    Text("Draw freely on digital canvases or pick fun templates to color and create!")
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
                
                // Action button to launch Doodle Studio
                NavigationLink(destination: DoodleView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text("Start Creative Doodle Studio")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.5, blue: 0.35)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Creative Drawing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CreativeDrawingHomeView()
    }
}
