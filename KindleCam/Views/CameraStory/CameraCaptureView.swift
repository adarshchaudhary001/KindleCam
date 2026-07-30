//
//  CameraCaptureView.swift
//  KindleCam
//
//  Child-friendly camera capture view using AVFoundation.
//  Displays a live camera preview with a playful shutter button.
//  On capture, sends the image to the ViewModel for processing.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Camera Capture View

public struct CameraCaptureView: View {
    @Bindable var viewModel: CameraStoryViewModel
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: CameraStoryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Camera Preview
            CameraPreviewRepresentable(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("Point at something cool! 📸")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Processing indicator
                if viewModel.phase == .detectingObjects || viewModel.phase == .generatingStory {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                        
                        Text(viewModel.phase == .detectingObjects
                             ? "Looking at your picture... 🔍"
                             : "Creating your story... ✨")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                
                Spacer()
                
                // Bottom: Shutter Button
                if viewModel.phase == .idle || viewModel.phase == .capturing {
                    VStack(spacing: 12) {
                        Text("Tap the button to take a picture!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Button(action: capturePhoto) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color(red: 0.48, green: 0.24, blue: 0.93))
                            }
                        }
                        .buttonStyle(ShutterButtonStyle())
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
    
    private func capturePhoto() {
        viewModel.phase = .capturing
        cameraManager.capturePhoto { image in
            guard let image else {
                // Use a placeholder if capture fails
                let fallbackImage = UIImage(systemName: "photo") ?? UIImage()
                Task {
                    await viewModel.processCapture(fallbackImage)
                }
                return
            }
            Task {
                await viewModel.processCapture(image)
            }
        }
    }
}

// MARK: - Shutter Button Style

private struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Camera Manager (AVFoundation)

private class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoContinuation: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoContinuation = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoContinuation?(nil)
            photoContinuation = nil
            return
        }
        photoContinuation?(image)
        photoContinuation = nil
    }
}

// MARK: - Camera Preview UIViewRepresentable

private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}
