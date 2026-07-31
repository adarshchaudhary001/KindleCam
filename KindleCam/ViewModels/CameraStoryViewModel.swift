//
//  CameraStoryViewModel.swift
//  KindleCam
//
//  Main ViewModel orchestrating the Camera Story feature flow.
//  Manages the state machine: idle → capturing → detecting → generating → adventure → completed.
//  Coordinates services (Vision, StoryGenerator, TaskVerification) and SwiftData persistence.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

/// State machine phases for the Camera Story feature.
public enum StoryPhase: Equatable {
    case idle
    case capturing
    case reviewing
    case detectingObjects
    case generatingStory
    case adventure
    case completed
}

/// Observable ViewModel for Camera Story.
@Observable
@MainActor
public final class CameraStoryViewModel {
    
    // MARK: - Published State
    
    public var phase: StoryPhase = .idle
    public var capturedImage: UIImage?
    public var detectedObjects: [CapturedObject] = []
    public var storyTitle: String = ""
    public var storyText: String = ""
    public var tasks: [StoryTask] = []
    public var currentTaskIndex: Int = 0
    public var feedbackMessage: String = ""
    public var showFeedback: Bool = false
    public var isCorrectFeedback: Bool = false
    public var errorMessage: String?
    
    /// The currently active task, or nil if all tasks are done.
    public var currentTask: StoryTask? {
        guard currentTaskIndex < tasks.count else { return nil }
        return tasks[currentTaskIndex]
    }
    
    /// Progress ratio (0.0 to 1.0) through the task list.
    public var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(currentTaskIndex) / Double(tasks.count)
    }
    
    /// Whether all tasks have been completed.
    public var allTasksCompleted: Bool {
        currentTaskIndex >= tasks.count
    }
    
    // MARK: - Services
    
    private let visionDetector = VisionObjectDetector()
    private let storyGenerator = StoryGeneratorService()
    private let verificationService = TaskVerificationService()
    
    // MARK: - Persistence
    
    private var modelContext: ModelContext?
    private var currentStory: CameraStory?
    
    public init() {}
    
    /// Set the ModelContext for SwiftData persistence.
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Feature Flow
    
    /// Step 1: Called when the child takes a photo — shows review screen.
    public func startReview(with image: UIImage) {
        capturedImage = image
        phase = .reviewing
    }
    
    /// Step 2: Called from ImageAnnotationView when user finishes circling objects.
    public func processAnnotatedRegions(circles: [CGRect], in viewSize: CGSize) async {
        guard let image = capturedImage else { return }
        phase = .detectingObjects
        errorMessage = nil
        
        var allObjects: [CapturedObject] = []
        
        for circle in circles {
            let croppedImage = cropImage(image, circleRect: circle, viewSize: viewSize)
            let objects = await visionDetector.detectObjects(in: croppedImage)
            allObjects.append(contentsOf: objects)
        }
        
        let dedupedObjects = deduplicate(objects: allObjects)
        detectedObjects = dedupedObjects
        
        await continueWithDetectedObjects(dedupedObjects)
    }
    
    /// Shared logic after objects are detected — generates story, creates records, transitions to adventure.
    private func continueWithDetectedObjects(_ objects: [CapturedObject]) async {
        phase = .generatingStory
        let generatedContent = await storyGenerator.generateStory(from: objects)
        
        storyTitle = generatedContent.title
        storyText = generatedContent.story
        
        var storyTasks: [StoryTask] = []
        for (index, taskContent) in generatedContent.tasks.enumerated() {
            let payloadJSON = encodePayload(taskContent.payload)
            let storyTask = StoryTask(
                orderIndex: index,
                taskType: taskContent.taskType,
                title: taskContent.title,
                storySegment: taskContent.storySegment,
                taskDescription: taskContent.taskDescription,
                difficulty: taskContent.difficulty,
                payloadJSON: payloadJSON
            )
            storyTasks.append(storyTask)
        }
        
        tasks = storyTasks
        currentTaskIndex = 0
        persistStory(generatedContent: generatedContent, tasks: storyTasks)
        phase = .adventure
    }
    
    /// Verify a quiz answer from the child.
    public func submitQuizAnswer(selectedIndex: Int) {
        guard let task = currentTask, let payload = task.payload else { return }
        
        let result = verificationService.verifyQuiz(selectedIndex: selectedIndex, payload: payload)
        handleVerification(result: result, task: task)
    }
    
    /// Verify a count answer from the child.
    public func submitCountAnswer(count: Int) {
        guard let task = currentTask, let payload = task.payload else { return }
        
        let result = verificationService.verifyCount(childCount: count, payload: payload)
        handleVerification(result: result, task: task)
    }
    
    /// Verify a tap task completion.
    public func submitTapCompletion(tappedCount: Int) {
        guard let task = currentTask, let payload = task.payload else { return }
        
        let result = verificationService.verifyTap(tappedCount: tappedCount, payload: payload)
        handleVerification(result: result, task: task)
    }
    
    /// Advance to the next task after successful completion.
    public func advanceToNextTask() {
        showFeedback = false
        currentTaskIndex += 1
        
        if allTasksCompleted {
            phase = .completed
        }
    }
    
    /// Reset the ViewModel for a new story session.
    public func reset() {
        phase = .idle
        capturedImage = nil
        detectedObjects = []
        storyTitle = ""
        storyText = ""
        tasks = []
        currentTaskIndex = 0
        feedbackMessage = ""
        showFeedback = false
        isCorrectFeedback = false
        errorMessage = nil
        currentStory = nil
    }
    
    // MARK: - Private Helpers
    
    private func handleVerification(result: TaskVerificationResult, task: StoryTask) {
        feedbackMessage = result.feedbackMessage
        isCorrectFeedback = result.isCorrect
        showFeedback = true
        
        // Log the performed action
        let record = ActionRecord(
            taskId: task.taskId,
            actionDescription: result.isCorrect ? "Correct" : "Incorrect"
        )
        currentStory?.performedActions.append(record)
        
        if result.isCorrect {
            // Mark the task as completed
            task.completed = true
            task.completionTime = Date()
            
            // Log correct action
            let correctRecord = ActionRecord(
                taskId: task.taskId,
                actionDescription: "Task completed successfully"
            )
            currentStory?.correctActions.append(correctRecord)
            
            // Save context
            try? modelContext?.save()
        }
    }
    
    private func persistStory(generatedContent: GeneratedStoryContent, tasks: [StoryTask]) {
        guard let modelContext else { return }
        
        let story = CameraStory(
            title: generatedContent.title,
            generatedStory: generatedContent.story,
            capturedObjects: detectedObjects,
            tasks: tasks
        )
        
        modelContext.insert(story)
        self.currentStory = story
        
        try? modelContext.save()
    }
    
    private func encodePayload(_ payload: TaskPayload) -> String {
        guard let data = try? JSONEncoder().encode(payload),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }
    
    /// Crop the precise region selected by the child (via finger or Apple Pencil).
    /// Safely maps view-space coordinates to image pixel coordinates with strict boundary checks.
    private func cropImage(_ image: UIImage, circleRect: CGRect, viewSize: CGSize) -> UIImage {
        guard let cgImage = image.cgImage, viewSize.width > 0, viewSize.height > 0 else {
            return image
        }
        
        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)
        
        // Calculate aspect fit drawing rect within the container view
        let scale = min(viewSize.width / image.size.width, viewSize.height / image.size.height)
        let drawWidth = image.size.width * scale
        let drawHeight = image.size.height * scale
        let xOffset = (viewSize.width - drawWidth) / 2
        let yOffset = (viewSize.height - drawHeight) / 2
        
        // Map circleRect from view space to image point space
        let imagePointX = (circleRect.origin.x - xOffset) / scale
        let imagePointY = (circleRect.origin.y - yOffset) / scale
        let imagePointW = circleRect.width / scale
        let imagePointH = circleRect.height / scale
        
        // Convert image points to CGImage pixel coordinates
        let pixelScaleX = pixelWidth / image.size.width
        let pixelScaleY = pixelHeight / image.size.height
        
        var pixelX = imagePointX * pixelScaleX
        var pixelY = imagePointY * pixelScaleY
        var pixelW = imagePointW * pixelScaleX
        var pixelH = imagePointH * pixelScaleY
        
        // Clamp crop bounds strictly within CGImage pixel dimensions
        pixelX = max(0, min(pixelX, pixelWidth - 1))
        pixelY = max(0, min(pixelY, pixelHeight - 1))
        pixelW = max(1, min(pixelW, pixelWidth - pixelX))
        pixelH = max(1, min(pixelH, pixelHeight - pixelY))
        
        let pixelCropRect = CGRect(x: pixelX, y: pixelY, width: pixelW, height: pixelH)
        
        if let croppedCGImage = cgImage.cropping(to: pixelCropRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }
    
    /// Deduplicate detected objects by label, keeping highest confidence.
    private func deduplicate(objects: [CapturedObject]) -> [CapturedObject] {
        var seenLabels = Set<String>()
        var result: [CapturedObject] = []
        for obj in objects.sorted(by: { $0.confidence > $1.confidence }) {
            let key = obj.label.lowercased().trimmingCharacters(in: .whitespaces)
            if !key.isEmpty && !seenLabels.contains(key) {
                seenLabels.insert(key)
                result.append(obj)
            }
        }
        return result
    }
}
