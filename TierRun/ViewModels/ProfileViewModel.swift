//
//  ProfileViewModel.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ProfileViewModel {
    
    var modelContext: ModelContext
    var user: User?
    var achievements: [Achievement] = []
    var titles: [Title] = []
    var equippedTitle: Title?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUser()
        loadAchievements()
        loadTitles()
    }
    
    func loadUser() {
        let descriptor = FetchDescriptor<User>()
        user = try? modelContext.fetch(descriptor).first
        equippedTitle = user?.equippedTitle
    }
    
    func loadAchievements() {
        guard let user = user else { return }
        
        var descriptor = FetchDescriptor<Achievement>()
        descriptor.sortBy = [SortDescriptor(\.unlockedAt, order: .reverse)]
        
        let allAchievements = (try? modelContext.fetch(descriptor)) ?? []
        achievements = allAchievements.filter { $0.user?.id == user.id }
    }
    
    func loadTitles() {
        guard let user = user else { return }
        
        var descriptor = FetchDescriptor<Title>()
        descriptor.sortBy = [SortDescriptor(\.unlockedAt, order: .reverse)]
        
        let allTitles = (try? modelContext.fetch(descriptor)) ?? []
        titles = allTitles.filter { $0.user?.id == user.id }
    }
    
    func equipTitle(_ title: Title) {
        // Unequip current title
        if let currentTitle = equippedTitle {
            currentTitle.isEquipped = false
        }
        
        // Equip new title
        title.isEquipped = true
        user?.equippedTitle = title
        equippedTitle = title
        
        try? modelContext.save()
    }
    
    func unequipTitle() {
        equippedTitle?.isEquipped = false
        user?.equippedTitle = nil
        equippedTitle = nil
        
        try? modelContext.save()
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    func getUnlockedTitles() -> [Title] {
        titles.filter { $0.isUnlocked }
    }
    
    func getTotalStats() -> ProfileStats {
        guard let user = user else {
            return ProfileStats(totalRuns: 0, totalDistance: 0, totalLP: 0)
        }
        
        var descriptor = FetchDescriptor<Run>()
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        
        let userRuns = allRuns.filter { $0.user?.id == user.id }
        
        let totalDistance = userRuns.reduce(0.0) { $0 + $1.distance }
        let totalLP = userRuns.reduce(0) { $0 + $1.lpEarned }
        
        return ProfileStats(
            totalRuns: userRuns.count,
            totalDistance: totalDistance,
            totalLP: totalLP
        )
    }
}

struct ProfileStats {
    let totalRuns: Int
    let totalDistance: Double
    let totalLP: Int
}
