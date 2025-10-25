//
//  Title.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftData

@Model
final class Title {
    @Attribute(.unique) var id: UUID
    var titleId: String
    var name: String
    var titleDescription: String
    var requirement: String
    var rarity: AchievementRarity
    var unlockedAt: Date?
    var isEquipped: Bool
    
    var user: User?
    
    init(
        id: UUID = UUID(),
        titleId: String,
        name: String,
        titleDescription: String,
        requirement: String,
        rarity: AchievementRarity,
        unlockedAt: Date? = nil,
        isEquipped: Bool = false
    ) {
        self.id = id
        self.titleId = titleId
        self.name = name
        self.titleDescription = titleDescription
        self.requirement = requirement
        self.rarity = rarity
        self.unlockedAt = unlockedAt
        self.isEquipped = isEquipped
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}
