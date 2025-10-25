//
//  ActivityViewModel.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ActivityViewModel {
    
    var modelContext: ModelContext
    var user: User?
    var runs: [Run] = []
    var filteredRuns: [Run] = []
    
    var selectedFilter: RunFilter = .all
    var selectedPeriod: TimePeriod = .all
    var sortOrder: SortOrder = .dateDescending
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUser()
        loadRuns()
    }
    
    func loadUser() {
        let descriptor = FetchDescriptor<User>()
        user = try? modelContext.fetch(descriptor).first
    }
    
    func loadRuns() {
        guard let user = user else { return }
        
        var descriptor = FetchDescriptor<Run>()
        
        // Apply sort
        switch sortOrder {
        case .dateDescending:
            descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        case .dateAscending:
            descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]
        case .distanceDescending:
            descriptor.sortBy = [SortDescriptor(\.distance, order: .reverse)]
        case .distanceAscending:
            descriptor.sortBy = [SortDescriptor(\.distance, order: .forward)]
        }
        
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        
        // Filter by user
        runs = allRuns.filter { $0.user?.id == user.id }
        
        applyFilters()
    }
    
    func applyFilters() {
        var filtered = runs
        
        // Role filter
        switch selectedFilter {
        case .all:
            break
        case .marathoner:
            filtered = filtered.filter { $0.role == .marathoner }
        case .sprinter:
            filtered = filtered.filter { $0.role == .sprinter }
        }
        
        // Period filter
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .all:
            break
        case .thisWeek:
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start {
                filtered = filtered.filter { $0.date >= weekStart }
            }
        case .thisMonth:
            if let monthStart = calendar.dateInterval(of: .month, for: now)?.start {
                filtered = filtered.filter { $0.date >= monthStart }
            }
        case .last30Days:
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            filtered = filtered.filter { $0.date >= thirtyDaysAgo }
        }
        
        filteredRuns = filtered
    }
    
    func deleteRun(_ run: Run) {
        modelContext.delete(run)
        try? modelContext.save()
        loadRuns()
    }
    
    func reclassifyRun(_ run: Run, to newRole: RunRole) {
        // Update role
        let oldRole = run.role
        run.role = newRole
        
        // Recalculate LP
        let oldLP = run.lpEarned
        run.lpEarned = TierCalculator.calculateLP(for: run, user: user)
        
        // Update tier LP
        if let user = user {
            if oldRole == .marathoner {
                user.marathonerTier?.lp -= oldLP
            } else {
                user.sprinterTier?.lp -= oldLP
            }
            
            if newRole == .marathoner {
                user.marathonerTier?.lp += run.lpEarned
            } else {
                user.sprinterTier?.lp += run.lpEarned
            }
        }
        
        try? modelContext.save()
        loadRuns()
    }
}

enum RunFilter: String, CaseIterable {
    case all = "All"
    case marathoner = "Marathoner"
    case sprinter = "Sprinter"
}

enum TimePeriod: String, CaseIterable {
    case all = "All Time"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case last30Days = "Last 30 Days"
}

enum SortOrder: String, CaseIterable {
    case dateDescending = "Date (Newest)"
    case dateAscending = "Date (Oldest)"
    case distanceDescending = "Distance (Longest)"
    case distanceAscending = "Distance (Shortest)"
}
