import SwiftUI

private struct FreehandSelection: Identifiable {
    let id = UUID()
    let points: [CGPoint]

    var boundingRect: CGRect {
        guard let first = points.first else { return .zero }
        var minX = first.x
        var maxX = first.x
        var minY = first.y
        var maxY = first.y
        for pt in points {
            minX = min(minX, pt.x)
            maxX = max(maxX, pt.x)
            minY = min(minY, pt.y)
            maxY = max(maxY, pt.y)
        }
        let padding: CGFloat = 10
        return CGRect(
            x: max(0, minX - padding),
            y: max(0, minY - padding),
            width: max(24, (maxX - minX) + padding * 2),
            height: max(24, (maxY - minY) + padding * 2)
        )
    }

    var center: CGPoint {
        let rect = boundingRect
        return CGPoint(x: rect.midX, y: rect.midY)
    }
}

public struct ImageAnnotationView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selections: [FreehandSelection] = []
    @State private var currentPoints: [CGPoint] = []
    @State private var viewSize: CGSize = .zero
    @State private var showProcessing: Bool = false

    private let defaultTapRadius: CGFloat = 45

    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showProcessing {
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.6)
                    Text("Looking at your picture... 🔍")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(28)
                .background(Color.black.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else if let image = viewModel.capturedImage {
                ZStack {
                    // Photo Display
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()

                    // Freehand Drawing Canvas for Apple Pencil and Finger
                    GeometryReader { geo in
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())

                            // Saved Freehand Selections
                            ForEach(selections) { sel in
                                FreehandSelectionShape(selection: sel, isActive: false)
                            }

                            // Active Stroke Being Drawn in Real-time
                            if !currentPoints.isEmpty {
                                FreehandSelectionShape(
                                    selection: FreehandSelection(points: currentPoints),
                                    isActive: true
                                )
                            }
                        }
                        .onAppear { viewSize = geo.size }
                        .onChange(of: geo.size) { _, newSize in viewSize = newSize }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    currentPoints.append(value.location)
                                }
                                .onEnded { value in
                                    if currentPoints.count > 2 {
                                        let selection = FreehandSelection(points: currentPoints)
                                        selections.append(selection)
                                    } else {
                                        // Single Tap: Draw a circular lasso around tapped point
                                        let tapCenter = value.startLocation
                                        var tapPoints: [CGPoint] = []
                                        let steps = 16
                                        for i in 0..<steps {
                                            let angle = (Double(i) / Double(steps)) * 2.0 * .pi
                                            let x = tapCenter.x + cos(angle) * defaultTapRadius
                                            let y = tapCenter.y + sin(angle) * defaultTapRadius
                                            tapPoints.append(CGPoint(x: x, y: y))
                                        }
                                        let tapSelection = FreehandSelection(points: tapPoints)
                                        selections.append(tapSelection)
                                    }
                                    currentPoints = []
                                }
                        )
                    }
                    .ignoresSafeArea()

                    // Top & Bottom Controls Overlay
                    VStack {
                        // Top Bar Controls
                        HStack {
                            Button(action: {
                                viewModel.phase = .idle
                                dismiss()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.white.opacity(0.95))
                                    .shadow(radius: 4)
                            }

                            Spacer()

                            Text("Draw around objects with Finger or Pencil ✏️")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())

                            Spacer()

                            if !selections.isEmpty {
                                Button(action: { selections.removeLast() }) {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.white.opacity(0.95))
                                        .shadow(radius: 4)
                                }
                            } else {
                                Color.clear.frame(width: 32, height: 32)
                            }
                        }
                        .padding()

                        Spacer()

                        // Bottom Action Controls
                        HStack(spacing: 16) {
                            if selections.isEmpty {
                                Button(action: processEntireImage) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Explore Whole Picture ✨")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                            .shadow(radius: 4)
                                    )
                                }
                            } else {
                                Button(action: processSelections) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles.magic")
                                            .font(.system(size: 18, weight: .bold))
                                        Text("Discover My Objects! (\(selections.count)) ✨")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 32)
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
                                            .shadow(color: Color(red: 0.48, green: 0.24, blue: 0.93).opacity(0.4), radius: 8, x: 0, y: 4)
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 36)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func processSelections() {
        showProcessing = true
        let selectionRects = selections.map { $0.boundingRect }
        Task {
            await viewModel.processAnnotatedRegions(circles: selectionRects, in: viewSize)
        }
    }

    private func processEntireImage() {
        showProcessing = true
        let fullRect = CGRect(origin: .zero, size: viewSize)
        Task {
            await viewModel.processAnnotatedRegions(circles: [fullRect], in: viewSize)
        }
    }
}

// MARK: - Freehand Selection View Component

private struct FreehandSelectionShape: View {
    let selection: FreehandSelection
    let isActive: Bool

    var body: some View {
        ZStack {
            // Filled interior path with subtle opacity
            Path { path in
                guard let first = selection.points.first else { return }
                path.move(to: first)
                for pt in selection.points.dropFirst() {
                    path.addLine(to: pt)
                }
                path.closeSubpath()
            }
            .fill(
                (isActive ? Color(red: 1.0, green: 0.8, blue: 0.2) : Color(red: 0.48, green: 0.24, blue: 0.93))
                    .opacity(0.2)
            )

            // Smooth freehand stroke
            Path { path in
                guard let first = selection.points.first else { return }
                path.move(to: first)
                for pt in selection.points.dropFirst() {
                    path.addLine(to: pt)
                }
                path.closeSubpath()
            }
            .stroke(
                isActive ? Color(red: 1.0, green: 0.8, blue: 0.2) : Color(red: 0.48, green: 0.24, blue: 0.93),
                style: StrokeStyle(lineWidth: isActive ? 3.5 : 4.5, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: (isActive ? Color.yellow : Color(red: 0.48, green: 0.24, blue: 0.93)).opacity(0.5), radius: 4)

            if !isActive {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color(red: 0.48, green: 0.24, blue: 0.93))
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .position(selection.center)
            }
        }
    }
}
