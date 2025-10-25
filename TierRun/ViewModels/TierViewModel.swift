//
//  TierViewModel.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class TierViewModel {
    
    var modelContext: ModelContext
    var user: User?
    var selectedRole: RunRole = .marathoner
    var isShowingCertificateGenerator = false
    
    var currentTier: Tier? {
        selectedRole == .marathoner ? user?.marathonerTier : user?.sprinterTier
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUser()
    }
    
    func loadUser() {
        let descriptor = FetchDescriptor<User>()
        user = try? modelContext.fetch(descriptor).first
    }
    
    func switchRole() {
        selectedRole = selectedRole == .marathoner ? .sprinter : .marathoner
    }
    
    func getTierStats() -> TierStats? {
        guard let user = user else { return nil }
        
        // Calculate stats
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        var descriptor = FetchDescriptor<Run>()
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        
        let weeklyRuns = allRuns.filter { run in
            run.user?.id == user.id &&
            run.date >= weekStart &&
            run.role == selectedRole
        }
        let weeklyLP = weeklyRuns.reduce(0) { $0 + $1.lpEarned }
        
        // Monthly LP
        let monthStart = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        let monthlyRuns = allRuns.filter { run in
            run.user?.id == user.id &&
            run.date >= monthStart &&
            run.role == selectedRole
        }
        let monthlyLP = monthlyRuns.reduce(0) { $0 + $1.lpEarned }
        
        // Season LP
        let seasonRuns = getSeasonRuns()
        let seasonLP = seasonRuns.reduce(0) { $0 + $1.lpEarned }
        
        return TierStats(
            weeklyLP: weeklyLP,
            monthlyLP: monthlyLP,
            seasonLP: seasonLP
        )
    }
    
    func getSeasonRuns() -> [Run] {
        guard let tier = currentTier, let user = user else { return [] }
        
        var descriptor = FetchDescriptor<Run>()
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        
        return allRuns.filter { run in
            run.user?.id == user.id &&
            run.date >= tier.seasonStartDate &&
            run.role == selectedRole
        }
    }
    
    func getRankPercentage() -> Double {
        // TODO: Calculate rank percentage based on all users
        // For now, return mock data based on tier
        guard let tier = currentTier else { return 50.0 }
        
        switch tier.currentTier {
        case .iron: return 95.0
        case .bronze: return 85.0
        case .silver: return 70.0
        case .gold: return 55.0
        case .platinum: return 40.0
        case .emerald: return 25.0
        case .diamond: return 15.0
        case .master: return 5.0
        case .grandmaster: return 2.0
        case .challenger: return 0.5
        }
    }
}

struct TierStats {
    let weeklyLP: Int
    let monthlyLP: Int
    let seasonLP: Int
}
