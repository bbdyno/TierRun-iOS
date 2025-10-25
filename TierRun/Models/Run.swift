//
//  Run.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Run {
    @Attribute(.unique) var id: UUID
    var date: Date
    var role: RunRole
    var distance: Double // km
    var duration: TimeInterval // seconds
    var averagePace: Double // min/km
    var averageHeartRate: Int
    var maxHeartRate: Int
    var calories: Int
    var route: [LocationPoint]
    var splits: [Split]
    var heartRateZones: [Int: TimeInterval]
    var elevationGain: Double
    var cadence: Int
    var lpEarned: Int
    var sourceApp: String? // "Apple Watch", "Nike Run Club", etc.
    
    var user: User?
    
    init(
        id: UUID = UUID(),
        date: Date,
        role: RunRole,
        distance: Double,
        duration: TimeInterval,
        averagePace: Double,
        averageHeartRate: Int,
        maxHeartRate: Int,
        calories: Int,
        route: [LocationPoint] = [],
        splits: [Split] = [],
        heartRateZones: [Int: TimeInterval] = [:],
        elevationGain: Double = 0,
        cadence: Int = 0,
        lpEarned: Int = 0,
        sourceApp: String? = nil
    ) {
        self.id = id
        self.date = date
        self.role = role
        self.distance = distance
        self.duration = duration
        self.averagePace = averagePace
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.calories = calories
        self.route = route
        self.splits = splits
        self.heartRateZones = heartRateZones
        self.elevationGain = elevationGain
        self.cadence = cadence
        self.lpEarned = lpEarned
        self.sourceApp = sourceApp
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedPace: String {
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}

struct LocationPoint: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let timestamp: Date
}

struct Split: Codable {
    let distance: Double
    let time: TimeInterval
    let pace: Double
    let heartRate: Int
}
