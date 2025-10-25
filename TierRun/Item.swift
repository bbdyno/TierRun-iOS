//
//  Item.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
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
