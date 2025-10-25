//
//  Achievement.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var achievementId: String
    var name: String
    var achievementDescription: String
    var icon: String
    var category: AchievementCategory
    var rarity: AchievementRarity
    var unlockedAt: Date?
    var progress: Double // 0.0 to 1.0
    var requirement: Double
    
    var user: User?
    
    init(
        id: UUID = UUID(),
        achievementId: String,
        name: String,
        achievementDescription: String,
        icon: String,
        category: AchievementCategory,
        rarity: AchievementRarity,
        unlockedAt: Date? = nil,
        progress: Double = 0.0,
        requirement: Double
    ) {
        self.id = id
        self.achievementId = achievementId
        self.name = name
        self.achievementDescription = achievementDescription
        self.icon = icon
        self.category = category
        self.rarity = rarity
        self.unlockedAt = unlockedAt
        self.progress = progress
        self.requirement = requirement
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}

enum AchievementCategory: String, Codable {
    case distance
    case frequency
    case streak
    case speed
    case special
}

enum AchievementRarity: String, Codable {
    case common
    case rare
    case epic
    case legendary
}
