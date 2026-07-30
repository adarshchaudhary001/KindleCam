//
//  NormalizedRect.swift
//  KindleCam
//
//  Custom struct representing normalized bounding box coordinates (0.0 to 1.0)
//  since SwiftData cannot model CGRect directly.
//

import Foundation
import CoreGraphics

/// Represents a bounding box in normalized coordinates (0.0 to 1.0).
public struct NormalizedRect: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double = 0.0, y: Double = 0.0, width: Double = 0.0, height: Double = 0.0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    /// Converts normalized coordinates to absolute CGRect for a given view/image container size.
    public func cgRect(in containerSize: CGSize) -> CGRect {
        let absX = CGFloat(x) * containerSize.width
        let absY = CGFloat(y) * containerSize.height
        let absW = CGFloat(width) * containerSize.width
        let absH = CGFloat(height) * containerSize.height
        return CGRect(x: absX, y: absY, width: absW, height: absH)
    }
    
    /// Creates a NormalizedRect from a CGRect and its container size.
    public init(from cgRect: CGRect, in containerSize: CGSize) {
        guard containerSize.width > 0, containerSize.height > 0 else {
            self.init(x: 0, y: 0, width: 0, height: 0)
            return
        }
        self.init(
            x: Double(cgRect.origin.x / containerSize.width),
            y: Double(cgRect.origin.y / containerSize.height),
            width: Double(cgRect.size.width / containerSize.width),
            height: Double(cgRect.size.height / containerSize.height)
        )
    }
}
