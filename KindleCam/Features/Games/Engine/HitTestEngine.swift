import SwiftUI
import CoreGraphics

class HitTestEngine {

    /// Calculates Euclidean distance d = sqrt((x2 - x1)^2 + (y2 - y1)^2) to find the object nearest to tapPoint within hitRadius.
    static func findObjectAtTapLocation(
        tapPoint: CGPoint,
        canvasSize: CGSize,
        objects: [PlacedObject],
        hitRadius: CGFloat = 65.0
    ) -> PlacedObject? {
        var closestObject: PlacedObject?
        var minDistance: CGFloat = .greatestFiniteMagnitude

        for object in objects {
            let realX = object.normalizedPosition.x * canvasSize.width
            let realY = object.normalizedPosition.y * canvasSize.height

            let dx = tapPoint.x - realX
            let dy = tapPoint.y - realY
            let distance = sqrt(dx * dx + dy * dy)

            let effectiveRadius = hitRadius * object.scale

            if distance <= effectiveRadius && distance < minDistance {
                minDistance = distance
                closestObject = object
            }
        }

        return closestObject
    }

    /// Evaluates if a tapped object is a valid target object for the current count question
    static func evaluateCountTap(tappedObject: PlacedObject) -> Bool {
        return tappedObject.isTarget && !tappedObject.isCounted
    }

    /// Calculates Euclidean distance for sequence items
    static func findSequenceItemAtTapLocation(
        tapPoint: CGPoint,
        canvasSize: CGSize,
        items: [SequenceItem],
        hitRadius: CGFloat = 70.0
    ) -> SequenceItem? {
        var closestItem: SequenceItem?
        var minDistance: CGFloat = .greatestFiniteMagnitude

        for item in items {
            let realX = item.normalizedPosition.x * canvasSize.width
            let realY = item.normalizedPosition.y * canvasSize.height

            let dx = tapPoint.x - realX
            let dy = tapPoint.y - realY
            let distance = sqrt(dx * dx + dy * dy)

            let effectiveRadius = hitRadius * item.scale

            if distance <= effectiveRadius && distance < minDistance {
                minDistance = distance
                closestItem = item
            }
        }

        return closestItem
    }

    /// Verifies if tapped sequence item is the expected next item in order
    static func evaluateSequenceTap(tappedItem: SequenceItem, expectedOrderIndex: Int) -> Bool {
        return tappedItem.targetOrder == expectedOrderIndex
    }

    /// Verifies if selected letter matches missing letter in Word Completion
    static func evaluateWordLetter(selectedLetter: Character, missingLetter: Character) -> Bool {
        return selectedLetter.lowercased() == missingLetter.lowercased()
    }
}
