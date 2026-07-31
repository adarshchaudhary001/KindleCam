//
//  doodle.swift
//  KindleCam
//
//  Created by Aakash Singh Ranswal on 31/07/26.
//

import Foundation

struct DoodleObject: Identifiable, Hashable {
    let id: String
    let assetName: String?
    let symbolName: String
    let title: String
    let ideas: String

    init(assetName: String? = nil, symbolName: String, title: String, ideas: String) {
        self.assetName = assetName
        self.symbolName = symbolName
        self.title = title
        self.ideas = ideas
        self.id = assetName ?? symbolName
    }
}
