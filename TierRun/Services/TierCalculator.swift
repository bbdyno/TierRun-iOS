//
//  TierCalculator.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation

class TierCalculator {
    
    // MARK: - Calculate LP for a Single Run
    
    static func calculateLP(for run: Run, user: User?) -> Int {
        guard let user = user else { return 0 }
        
        var baseLP: Double = 0
        
        // Base LP from distance
        baseLP += calculateDistanceLP(
            distance: run.distance,
            role: run.role
        )
        
        // Performance modifier (pace)
        let paceModifier = calculatePaceModifier(
            pace: run.averagePace,
            distance: run.distance,
            role: run.role,
            user: user
        )
        baseLP *= paceModifier
        
        // Heart rate management bonus
        let hrBonus = calculateHeartRateBonus(
            averageHR: run.averageHeartRate,
            maxHR: run.maxHeartRate,
            user: user
        )
        baseLP += hrBonus
        
        // Consistency bonus (if running regularly)
        // This would need historical data - placeholder for now
        
        // Difficulty adjustment (elevation)
        let elevationBonus = run.elevationGain * 0.1
        baseLP += elevationBonus
        
        // Experience adjustment
        let experienceModifier = getExperienceModifier(user.experience)
        baseLP *= experienceModifier
        
        // Age adjustment (older runners get slight bonus)
        let ageModifier = getAgeModifier(user.age)
        baseLP *= ageModifier
        
        return max(1, Int(baseLP))
    }
    
    private static func calculateDistanceLP(distance: Double, role: RunRole) -> Double {
        switch role {
        case .marathoner:
            // Marathoner: rewards longer distances
            if distance >= 20 {
                return 50 + (distance - 20) * 3
            } else if distance >= 10 {
                return 30 + (distance - 10) * 2
            } else if distance >= 5 {
                return 15 + (distance - 5) * 3
            } else {
                return distance * 3
            }
            
        case .sprinter:
            // Sprinter: rewards shorter, faster runs
            if distance >= 5 {
                return 20 + (distance - 5) * 1
            } else if distance >= 3 {
                return 15 + (distance - 3) * 2.5
            } else {
                return distance * 5
            }
        }
    }
    
    private static func calculatePaceModifier(
        pace: Double,
        distance: Double,
        role: RunRole,
        user: User
    ) -> Double {
        // Get expected pace for user
        let expectedPace = getExpectedPace(
            distance: distance,
            role: role,
            age: user.age,
            gender: user.gender,
            experience: user.experience
        )
        
        let paceRatio = expectedPace / pace
        
        // Better than expected: bonus
        if paceRatio < 1.0 {
            return 1.0 + (1.0 - paceRatio) * 0.5
        }
        // Worse than expected: penalty
        else if paceRatio > 1.2 {
            return 0.8
        }
        // Around expected: normal
        else {
            return 1.0
        }
    }
    
    private static func getExpectedPace(
        distance: Double,
        role: RunRole,
        age: Int,
        gender: Gender,
        experience: Experience
    ) -> Double {
        // Base expected pace (min/km)
        var basePace: Double
        
        switch role {
        case .marathoner:
            basePace = 6.0 // 6:00/km baseline
        case .sprinter:
            basePace = 4.5 // 4:30/km baseline
        }
        
        // Age adjustment
        if age < 25 {
            basePace -= 0.3
        } else if age > 40 {
            basePace += Double(age - 40) * 0.05
        }
        
        // Gender adjustment
        if gender == .female {
            basePace += 0.5
        }
        
        // Experience adjustment
        switch experience {
        case .beginner:
            basePace += 1.0
        case .intermediate:
            basePace += 0.3
        case .advanced:
            basePace -= 0.5
        case .elite:
            basePace -= 1.0
        }
        
        // Distance adjustment (longer runs = slower pace is ok)
        if distance > 15 {
            basePace += 0.5
        } else if distance > 10 {
            basePace += 0.3
        }
        
        return max(4.0, basePace)
    }
    
    private static func calculateHeartRateBonus(
        averageHR: Int,
        maxHR: Int,
        user: User
    ) -> Double {
        // Calculate max heart rate estimate
        let estimatedMaxHR = 220 - user.age
        
        // Calculate percentage of max
        let avgPercentage = Double(averageHR) / Double(estimatedMaxHR)
        
        // Reward good heart rate management
        // Zone 2-3 (60-80%) is ideal for base building
        if avgPercentage >= 0.6 && avgPercentage <= 0.8 {
            return 5.0 // Bonus for good zone
        } else if avgPercentage > 0.9 {
            return 2.0 // High intensity - some bonus
        } else {
            return 0.0
        }
    }
    
    private static func getExperienceModifier(_ experience: Experience) -> Double {
        switch experience {
        case .beginner:
            return 1.3 // Encourage beginners
        case .intermediate:
            return 1.1
        case .advanced:
            return 1.0
        case .elite:
            return 0.9 // Elite runners need more to rank up
        }
    }
    
    private static func getAgeModifier(_ age: Int) -> Double {
        if age < 20 {
            return 1.0
        } else if age < 30 {
            return 1.0
        } else if age < 40 {
            return 1.05
        } else if age < 50 {
            return 1.1
        } else if age < 60 {
            return 1.15
        } else {
            return 1.2
        }
    }
    
    // MARK: - Calculate Initial Tier (Placement)
    
    static func calculateInitialTier(
        workouts: [WorkoutData],
        user: User
    ) -> (tier: TierLevel, grade: Int) {
        
        guard !workouts.isEmpty else {
            return (.iron, 4) // Start at Iron 4 if no data
        }
        
        // Calculate average performance
        let avgDistance = workouts.reduce(0.0) { $0 + $1.distance } / Double(workouts.count)
        let avgPace = workouts.reduce(0.0) { $0 + $1.averagePace } / Double(workouts.count)
        let totalWorkouts = workouts.count
        
        // Calculate simulated LP
        var totalLP = 0
        for workout in workouts {
            // Create temporary Run for LP calculation
            let tempRun = Run(
                date: workout.date,
                role: workout.role,
                distance: workout.distance,
                duration: workout.duration,
                averagePace: workout.averagePace,
                averageHeartRate: workout.averageHeartRate,
                maxHeartRate: workout.maxHeartRate,
                calories: workout.calories,
                elevationGain: workout.elevationGain,
                cadence: workout.cadence
            )
            
            totalLP += calculateLP(for: tempRun, user: user)
        }
        
        // Adjust for frequency (more consistent = higher placement)
        let frequencyBonus = min(totalWorkouts * 10, 200)
        totalLP += frequencyBonus
        
        // Convert LP to tier
        return lpToTier(totalLP)
    }
    
    private static func lpToTier(_ lp: Int) -> (tier: TierLevel, grade: Int) {
        let allTiers: [TierLevel] = [
            .iron, .bronze, .silver, .gold, .platinum,
            .emerald, .diamond, .master, .grandmaster, .challenger
        ]
        
        for tier in allTiers.reversed() {
            if lp >= tier.baseLP {
                // Calculate grade (1-4)
                let lpInTier = lp - tier.baseLP
                let grade = 4 - min(lpInTier / 200, 3)
                return (tier, grade)
            }
        }
        
        return (.iron, 4)
    }
    
    // MARK: - Tier Progression
    
    static func checkTierPromotion(tier: Tier) -> TierPromotionResult {
        let currentTierIndex = TierLevel.allCases.firstIndex(of: tier.currentTier) ?? 0
        
        // Check if LP is enough for next tier
        if tier.lp >= tier.nextTierLP {
            // Check if at grade 1
            if tier.currentGrade == 1 {
                // Promotion to next tier
                if currentTierIndex < TierLevel.allCases.count - 1 {
                    return .promotion(nextTier: TierLevel.allCases[currentTierIndex + 1])
                } else {
                    // Already at Challenger
                    return .noChange
                }
            } else {
                // Grade up
                return .gradeUp
            }
        }
        
        return .noChange
    }
    
    static func applyPromotion(tier: Tier, result: TierPromotionResult) {
        switch result {
        case .promotion(let nextTier):
            // Save to history
            let historyEntry = TierHistoryEntry(
                date: Date(),
                tier: tier.currentTier,
                grade: tier.currentGrade,
                lp: tier.lp
            )
            tier.tierHistory.append(historyEntry)
            
            // Promote
            tier.currentTier = nextTier
            tier.currentGrade = 4
            tier.lp = nextTier.baseLP
            
        case .gradeUp:
            tier.currentGrade -= 1
            
        case .noChange:
            break
        }
    }
}

enum TierPromotionResult {
    case promotion(nextTier: TierLevel)
    case gradeUp
    case noChange
}
