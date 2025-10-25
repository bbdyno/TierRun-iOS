//
//  HealthKitManager.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import HealthKit
import CoreLocation

struct WorkoutData {
    let id: UUID
    let date: Date
    let role: RunRole
    let distance: Double // km
    let duration: TimeInterval // seconds
    let averagePace: Double // min/km
    let averageHeartRate: Int
    let maxHeartRate: Int
    let calories: Int
    let route: [LocationPoint]
    let elevationGain: Double
    let cadence: Int
    let sourceApp: String?
}

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.quantityType(forIdentifier: .runningPower)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKSeriesType.workoutRoute()
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Fetch Workouts
    
    func fetchRecentWorkouts(months: Int = 1) async throws -> [WorkoutData] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: endDate) else {
            throw HealthKitError.invalidDate
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, datePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }
                
                Task {
                    var workoutDataArray: [WorkoutData] = []
                    
                    for workout in workouts {
                        if let workoutData = await self.processWorkout(workout) {
                            workoutDataArray.append(workoutData)
                        }
                    }
                    
                    continuation.resume(returning: workoutDataArray)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func processWorkout(_ workout: HKWorkout) async -> WorkoutData? {
        let distance = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
        let duration = workout.duration
        
        // Skip very short workouts
        guard distance > 0.5, duration > 300 else { return nil } // at least 0.5km and 5 minutes
        
        let averagePace = (duration / 60.0) / distance // min/km
        
        // Classify as marathoner or sprinter based on distance and pace
        let role = classifyRunRole(distance: distance, pace: averagePace)
        
        // Fetch heart rate data
        let (avgHR, maxHR) = await fetchHeartRateData(for: workout)
        
        // Fetch route
        let route = await fetchRoute(for: workout)
        
        // Fetch elevation
        let elevation = await fetchElevationGain(for: workout)
        
        // Fetch cadence
        let cadence = await fetchCadence(for: workout)
        
        // Get source app name
        let sourceApp = workout.sourceRevision.source.name
        
        let calories = Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
        
        return WorkoutData(
            id: workout.uuid,
            date: workout.startDate,
            role: role,
            distance: distance,
            duration: duration,
            averagePace: averagePace,
            averageHeartRate: avgHR,
            maxHeartRate: maxHR,
            calories: calories,
            route: route,
            elevationGain: elevation,
            cadence: cadence,
            sourceApp: sourceApp != "TierRun" ? sourceApp : nil
        )
    }
    
    private func classifyRunRole(distance: Double, pace: Double) -> RunRole {
        // Marathoner: longer distances (> 5km) or slower pace
        // Sprinter: shorter distances (< 5km) and faster pace
        
        if distance >= 5.0 {
            return .marathoner
        } else if distance < 3.0 && pace < 5.0 {
            return .sprinter
        } else {
            // Use pace to decide
            return pace > 5.5 ? .marathoner : .sprinter
        }
    }
    
    // MARK: - Heart Rate
    
    private func fetchHeartRateData(for workout: HKWorkout) async -> (average: Int, max: Int) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: [.discreteAverage, .discreteMax]
            ) { _, statistics, _ in
                let avgHR = statistics?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                let maxHR = statistics?.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
                
                continuation.resume(returning: (Int(avgHR), Int(maxHR)))
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchRestingHeartRate() async throws -> Int {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: 60)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: Int(bpm))
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Route
    
    private func fetchRoute(for workout: HKWorkout) async -> [LocationPoint] {
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        return await withCheckedContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: routeType,
                predicate: predicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit
            ) { _, samples, _, _, _ in
                guard let routes = samples as? [HKWorkoutRoute],
                      let route = routes.first else {
                    continuation.resume(returning: [])
                    return
                }
                
                Task {
                    let locations = await self.fetchRouteLocations(for: route)
                    continuation.resume(returning: locations)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchRouteLocations(for route: HKWorkoutRoute) async -> [LocationPoint] {
        await withCheckedContinuation { continuation in
            var locations: [LocationPoint] = []
            
            let query = HKWorkoutRouteQuery(route: route) { _, routeData, done, _ in
                if let routeData = routeData {
                    for location in routeData {
                        locations.append(LocationPoint(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude,
                            altitude: location.altitude,
                            timestamp: location.timestamp
                        ))
                    }
                }
                
                if done {
                    continuation.resume(returning: locations)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Elevation
    
    private func fetchElevationGain(for workout: HKWorkout) async -> Double {
        // Try to get from workout metadata first
        if let elevation = workout.metadata?[HKMetadataKeyElevationAscended] as? HKQuantity {
            return elevation.doubleValue(for: .meter())
        }
        
        // Calculate from route if available
        let route = await fetchRoute(for: workout)
        guard route.count > 1 else { return 0 }
        
        var gain: Double = 0
        for i in 1..<route.count {
            let diff = route[i].altitude - route[i-1].altitude
            if diff > 0 {
                gain += diff
            }
        }
        
        return gain
    }
    
    // MARK: - Cadence
    
    private func fetchCadence(for workout: HKWorkout) async -> Int {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 170 // Default cadence estimate
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                guard let totalSteps = statistics?.sumQuantity()?.doubleValue(for: .count()),
                      totalSteps > 0,
                      workout.duration > 0 else {
                    // Return typical running cadence if we can't calculate
                    continuation.resume(returning: 170)
                    return
                }
                
                // Calculate cadence (steps per minute)
                let durationInMinutes = workout.duration / 60.0
                let cadence = Int(totalSteps / durationInMinutes)
                
                // Clamp to reasonable running cadence range (140-200 spm)
                let clampedCadence = max(140, min(200, cadence))
                continuation.resume(returning: clampedCadence)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Sleep
    
    func fetchSleepHours() async throws -> Double {
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw HealthKitError.invalidDate
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 7.0)
                    return
                }
                
                var totalSleepTime: TimeInterval = 0
                
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
                
                let hours = totalSleepTime / 3600.0
                continuation.resume(returning: hours)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Activity
    
    func fetchDailySteps() async throws -> Int {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.startOfDay(for: endDate) else {
            throw HealthKitError.invalidDate
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
}

enum HealthKitError: Error {
    case notAvailable
    case invalidDate
    case unauthorized
    case noData
}

extension Calendar {
    func startOfDay(for date: Date) -> Date? {
        var calendar = self
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
}
