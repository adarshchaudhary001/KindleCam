//
//  Item.swift
//  KindleCam
//
//  Created by Aakash Singh Ranswal on 28/07/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
