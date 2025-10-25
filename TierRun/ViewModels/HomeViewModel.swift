//
//  HomeViewModel.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@Observable
class HomeViewModel {
    
    var modelContext: ModelContext
    var user: User?
    var recentRuns: [Run] = []
    var conditionScore: Int = 0
    var sleepHours: Double = 0
    var restingHeartRate: Int = 0
    var weeklyProgress: WeeklyProgress?
    var isSyncing: Bool = false
    var lastSyncDate: Date?
    
    private let healthKitManager = HealthKitManager.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUser()
        loadRecentRuns()
        loadCondition()
        loadWeeklyProgress()
    }
    
    func loadUser() {
        let descriptor = FetchDescriptor<User>()
        user = try? modelContext.fetch(descriptor).first
    }
    
    func loadRecentRuns() {
        guard let user = user else { return }
        
        var descriptor = FetchDescriptor<Run>()
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = 3
        
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        recentRuns = allRuns.filter { $0.user?.id == user.id }
    }
    
    func loadCondition() {
        Task {
            do {
                let sleep = try await healthKitManager.fetchSleepHours()
                let hr = try await healthKitManager.fetchRestingHeartRate()
                
                await MainActor.run {
                    self.sleepHours = sleep
                    self.restingHeartRate = hr
                    self.conditionScore = calculateConditionScore(sleep: sleep, hr: hr)
                }
            } catch {
                print("Error loading condition: \(error)")
            }
        }
    }
    
    func loadWeeklyProgress() {
        guard let user = user else { return }
        
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        var descriptor = FetchDescriptor<Run>()
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        
        let weeklyRuns = allRuns.filter { run in
            run.user?.id == user.id && run.date >= weekStart
        }
        
        let totalDistance = weeklyRuns.reduce(0) { $0 + $1.distance }
        let totalLP = weeklyRuns.reduce(0) { $0 + $1.lpEarned }
        
        weeklyProgress = WeeklyProgress(
            completedRuns: weeklyRuns.count,
            targetRuns: 3,
            totalDistance: totalDistance,
            totalLP: totalLP
        )
    }
    
    func syncHealthKit() {
        isSyncing = true
        
        Task {
            do {
                let newRuns = try await healthKitManager.fetchRecentWorkouts()
                
                await MainActor.run {
                    for runData in newRuns {
                        // Check if run already exists
                        let existingRun = checkIfRunExists(id: runData.id)
                        if existingRun != nil {
                            continue // Skip if already synced
                        }
                        
                        let run = Run(
                            id: runData.id,
                            date: runData.date,
                            role: runData.role,
                            distance: runData.distance,
                            duration: runData.duration,
                            averagePace: runData.averagePace,
                            averageHeartRate: runData.averageHeartRate,
                            maxHeartRate: runData.maxHeartRate,
                            calories: runData.calories,
                            route: runData.route,
                            elevationGain: runData.elevationGain,
                            cadence: runData.cadence,
                            sourceApp: runData.sourceApp
                        )
                        
                        // Calculate LP
                        run.lpEarned = TierCalculator.calculateLP(for: run, user: user)
                        
                        run.user = user
                        modelContext.insert(run)
                        
                        // Update tier LP
                        updateTierLP(run: run)
                    }
                    
                    try? modelContext.save()
                    
                    loadRecentRuns()
                    loadWeeklyProgress()
                    
                    lastSyncDate = Date()
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                }
                print("Error syncing: \(error)")
            }
        }
    }
    
    private func checkIfRunExists(id: UUID) -> Run? {
        var descriptor = FetchDescriptor<Run>()
        let allRuns = (try? modelContext.fetch(descriptor)) ?? []
        return allRuns.first { $0.id == id }
    }
    
    private func updateTierLP(run: Run) {
        guard let user = user else { return }
        
        if run.role == .marathoner {
            user.marathonerTier?.lp += run.lpEarned
        } else {
            user.sprinterTier?.lp += run.lpEarned
        }
    }
    
    private func calculateConditionScore(sleep: Double, hr: Int) -> Int {
        var score = 50
        
        // Sleep score (max 30 points)
        if sleep >= 8 {
            score += 30
        } else if sleep >= 7 {
            score += 25
        } else if sleep >= 6 {
            score += 15
        } else {
            score += 5
        }
        
        // Heart rate score (max 20 points)
        if hr < 60 {
            score += 20
        } else if hr < 70 {
            score += 15
        } else if hr < 80 {
            score += 10
        } else {
            score += 5
        }
        
        return min(score, 100)
    }
}

struct WeeklyProgress {
    let completedRuns: Int
    let targetRuns: Int
    let totalDistance: Double
    let totalLP: Int
    
    var progress: Double {
        Double(completedRuns) / Double(targetRuns)
    }
}
