//
//  DoodleViewModel.swift
//  KindleCam
//
//  ViewModel for Creative Doodle interactive drawing canvas.
//

import Combine
import PencilKit
import SwiftUI

public enum DrawingTool: String, CaseIterable, Identifiable {
    case pencil, marker, crayon
    public var id: String { rawValue }
    public var label: String { rawValue.capitalized }
    public var symbol: String { self == .pencil ? "pencil.tip" : self == .marker ? "highlighter" : "paintbrush.pointed" }
}

public final class DoodleViewModel: ObservableObject {
    @Published public var shapes: [DoodleObject] = [
        .init(assetName: "spoon", symbolName: "spoon", title: "Spoon", ideas: "a giraffe, bunny, guitar, or rocket"),
        .init(assetName: "cloud", symbolName: "cloud.fill", title: "Cloud", ideas: "a sheep, dragon, or castle"),
        .init(assetName: "moon", symbolName: "moon.fill", title: "Moon", ideas: "a banana, smile, or hammock"),
        .init(assetName: "umbrella", symbolName: "umbrella.fill", title: "Umbrella", ideas: "a jellyfish, mushroom, or tent"),
        .init(assetName: "drop", symbolName: "drop.fill", title: "Drop", ideas: "a fish, flame, or jellyfish"),
        .init(symbolName: "star.fill", title: "Star", ideas: "a superhero, flower, or magic wand"),
        .init(symbolName: "heart.fill", title: "Heart", ideas: "a butterfly, strawberry, or hot-air balloon"),
        .init(symbolName: "circle.fill", title: "Circle", ideas: "a turtle, clock, or planet"),
        .init(symbolName: "triangle.fill", title: "Triangle", ideas: "a mountain, fox, or sailboat")
    ]

    @Published public var selectedShape: DoodleObject?
    @Published public var drawing: PKDrawing = PKDrawing()
    @Published public var selectedColor: Color = Color(red: 1.0, green: 0.35, blue: 0.35)
    @Published public var selectedTool: DrawingTool = .marker
    @Published public var lineWidth: CGFloat = 14
    @Published public var isEraserActive = false
    @Published public var clearTrigger = UUID()
    @Published public var undoTrigger = UUID()
    @Published public var saveTrigger = UUID()
    @Published public var saveMessage: String?
    @Published public var currentTool: PKTool = PKInkingTool(.marker, color: UIColor(Color(red: 1.0, green: 0.35, blue: 0.35)), width: 14)

    public let availableColors: [Color] = [
        Color(red: 1.0, green: 0.35, blue: 0.35),
        .orange,
        .yellow,
        .green,
        .mint,
        .blue,
        .purple,
        .pink,
        .brown,
        .black
    ]

    public init() {
        selectedShape = shapes.first
        updateTool()
    }

    public func selectShape(_ shape: DoodleObject) {
        selectedShape = shape
        clearCanvas()
    }

    public func clearCanvas() {
        drawing = PKDrawing()
        clearTrigger = UUID()
    }

    public func undo() {
        undoTrigger = UUID()
    }

    public func saveDrawing() {
        saveMessage = "Saving your masterpiece…"
        saveTrigger = UUID()
    }

    public func saveFinished(success: Bool) {
        saveMessage = success ? "Saved to Photos!" : "Photos permission is needed to save."
    }

    public func selectColor(_ color: Color) {
        selectedColor = color
        isEraserActive = false
        updateTool()
    }

    public func selectTool(_ tool: DrawingTool) {
        selectedTool = tool
        isEraserActive = false
        updateTool()
    }

    public func toggleEraser() {
        isEraserActive.toggle()
        updateTool()
    }

    public func updateTool() {
        if isEraserActive {
            currentTool = PKEraserTool(.vector)
            return
        }
        let ink: PKInkingTool.InkType = selectedTool == .pencil ? .pencil : selectedTool == .marker ? .marker : .crayon
        currentTool = PKInkingTool(ink, color: UIColor(selectedColor), width: lineWidth)
    }
}
