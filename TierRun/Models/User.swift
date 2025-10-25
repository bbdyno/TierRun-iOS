//
//  User.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var weight: Double
    var experience: Experience
    var mainRole: RunRole
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var marathonerTier: Tier?
    @Relationship(deleteRule: .cascade) var sprinterTier: Tier?
    @Relationship(deleteRule: .cascade) var runs: [Run] = []
    @Relationship(deleteRule: .cascade) var achievements: [Achievement] = []
    @Relationship(deleteRule: .cascade) var equippedTitle: Title?
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        gender: Gender,
        weight: Double,
        experience: Experience,
        mainRole: RunRole,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.weight = weight
        self.experience = experience
        self.mainRole = mainRole
        self.createdAt = createdAt
    }
}

enum Gender: String, Codable {
    case male
    case female
    case other
}

enum Experience: String, Codable {
    case beginner
    case intermediate
    case advanced
    case elite
}

enum RunRole: String, Codable {
    case marathoner
    case sprinter
}
