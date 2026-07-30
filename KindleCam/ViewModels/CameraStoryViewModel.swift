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
    
    /// Step 1: Called when the child takes a photo.
    public func processCapture(_ image: UIImage) async {
        capturedImage = image
        phase = .detectingObjects
        errorMessage = nil
        
        // Step 2: Detect objects using Vision
        let objects = await visionDetector.detectObjects(in: image)
        detectedObjects = objects
        
        // Step 3: Generate story from detected objects
        phase = .generatingStory
        let generatedContent = await storyGenerator.generateStory(from: objects)
        
        // Step 4: Create SwiftData records and transition to adventure
        storyTitle = generatedContent.title
        storyText = generatedContent.story
        
        // Convert GeneratedTaskContent → StoryTask
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
        
        // Persist to SwiftData
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
}
