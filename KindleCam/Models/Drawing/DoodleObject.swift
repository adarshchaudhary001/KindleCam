//
//  DoodleObject.swift
//  KindleCam
//
//  Data model representing a template shape for creative doodle drawing.
//

import Foundation

public struct DoodleObject: Identifiable, Hashable {
    public let id: String
    public let assetName: String?
    public let symbolName: String
    public let title: String
    public let ideas: String

    public init(assetName: String? = nil, symbolName: String, title: String, ideas: String) {
        self.assetName = assetName
        self.symbolName = symbolName
        self.title = title
        self.ideas = ideas
        self.id = assetName ?? symbolName
    }
}
