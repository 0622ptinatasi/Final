//
//  Item.swift
//  Final
//
//  Created by user12 on 2024/12/5.
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
