//
//  SavedDrawing.swift
//  KindleCam
//
//  SwiftData @Model representing a user-created drawing session.
//  Large blob fields (thumbnail, drawingData) use @Attribute(.externalStorage)
//  to keep the main SQLite database light and small.
//

import Foundation
import SwiftData

@Model
public final class SavedDrawing {
    public var id: UUID
    public var title: String
    
    /// External storage for raster image thumbnail.
    @Attribute(.externalStorage)
    public var thumbnail: Data?
    
    public var creationDate: Date
    public var lastEdited: Date
    public var canvasWidth: Double
    public var canvasHeight: Double
    
    /// External storage for PKDrawing.dataRepresentation() or rendered raster image bytes.
    @Attribute(.externalStorage)
    public var drawingData: Data?
    
    /// Flag indicating whether this artwork was exported to the device Photo Library.
    public var exportedToGallery: Bool
    
    /// Soft reference to DrawingTemplate.id (nil for free drawings).
    /// Kept as plain UUID? so deleting or updating a template doesn't cascade-delete or corrupt finished user art.
    public var templateId: UUID?

    public init(
        id: UUID = UUID(),
        title: String = "",
        thumbnail: Data? = nil,
        creationDate: Date = Date(),
        lastEdited: Date = Date(),
        canvasWidth: Double = 0.0,
        canvasHeight: Double = 0.0,
        drawingData: Data? = nil,
        exportedToGallery: Bool = false,
        templateId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.creationDate = creationDate
        self.lastEdited = lastEdited
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.drawingData = drawingData
        self.exportedToGallery = exportedToGallery
        self.templateId = templateId
    }
}
