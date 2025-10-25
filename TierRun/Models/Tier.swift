//
//  Tier.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftData

@Model
final class Tier {
    @Attribute(.unique) var id: UUID
    var role: RunRole
    var currentTier: TierLevel
    var currentGrade: Int // 1-4
    var lp: Int
    var seasonStartDate: Date
    var tierHistory: [TierHistoryEntry]
    
    var user: User?
    
    init(
        id: UUID = UUID(),
        role: RunRole,
        currentTier: TierLevel = .iron,
        currentGrade: Int = 4,
        lp: Int = 0,
        seasonStartDate: Date = Date(),
        tierHistory: [TierHistoryEntry] = []
    ) {
        self.id = id
        self.role = role
        self.currentTier = currentTier
        self.currentGrade = currentGrade
        self.lp = lp
        self.seasonStartDate = seasonStartDate
        self.tierHistory = tierHistory
    }
    
    var tierName: String {
        "\(currentTier.rawValue.capitalized) \(currentGrade)"
    }
    
    var nextTierLP: Int {
        return (currentTier.baseLP + (4 - currentGrade) * 200) + 200
    }
    
    var progressToNextTier: Double {
        let currentBase = currentTier.baseLP + (4 - currentGrade) * 200
        let nextBase = nextTierLP
        return Double(lp - currentBase) / Double(nextBase - currentBase)
    }
}

enum TierLevel: String, Codable, CaseIterable {
    case iron
    case bronze
    case silver
    case gold
    case platinum
    case emerald
    case diamond
    case master
    case grandmaster
    case challenger
    
    var baseLP: Int {
        switch self {
        case .iron: return 0
        case .bronze: return 800
        case .silver: return 1600
        case .gold: return 2400
        case .platinum: return 3200
        case .emerald: return 4000
        case .diamond: return 4800
        case .master: return 5600
        case .grandmaster: return 6400
        case .challenger: return 7200
        }
    }
    
    var color: String {
        switch self {
        case .iron: return "gray"
        case .bronze: return "brown"
        case .silver: return "silver"
        case .gold: return "yellow"
        case .platinum: return "cyan"
        case .emerald: return "green"
        case .diamond: return "blue"
        case .master: return "purple"
        case .grandmaster: return "red"
        case .challenger: return "rainbow"
        }
    }
}

struct TierHistoryEntry: Codable {
    let date: Date
    let tier: TierLevel
    let grade: Int
    let lp: Int
}
