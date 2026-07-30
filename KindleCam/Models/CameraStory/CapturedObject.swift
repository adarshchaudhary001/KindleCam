//
//  CapturedObject.swift
//  KindleCam
//
//  Embedded Codable struct representing object detection metadata within a frame.
//  Images are saved to disk (imageReference filename), not stored directly as Data in the model.
//

import Foundation

/// Embedded metadata for a detected object in a camera frame.
public struct CapturedObject: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var label: String
    /// Vision confidence score (converted from VNConfidence Float to Double).
    public var confidence: Double
    public var boundingBox: NormalizedRect
    /// Filename reference to cropped object image saved in Documents directory.
    public var imageReference: String?
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        label: String = "",
        confidence: Double = 0.0,
        boundingBox: NormalizedRect = NormalizedRect(),
        imageReference: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.imageReference = imageReference
        self.timestamp = timestamp
    }
}
