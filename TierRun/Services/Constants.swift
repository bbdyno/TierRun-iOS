//
//  Constants.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - App Info
    static let appName = "TierRun"
    static let appVersion = "1.0.0"
    static let appBundleId = "com.tngtng.TierRun"
    
    // MARK: - URLs
    static let websiteURL = URL(string: "https://tierrun.app")!
    static let termsURL = URL(string: "https://tierrun.app/terms")!
    static let privacyURL = URL(string: "https://tierrun.app/privacy")!
    static let supportURL = URL(string: "https://tierrun.app/support")!
    
    // MARK: - Donation Addresses (이상한 값 넣어둔 상태이고 실제 지갑 값 넣어야 함)
    static let bitcoinAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
    static let ethereumAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    
    // MARK: - Tier Colors
    static let tierColors: [TierLevel: Color] = [
        .iron: .gray,
        .bronze: .brown,
        .silver: Color(red: 0.75, green: 0.75, blue: 0.75),
        .gold: .yellow,
        .platinum: .cyan,
        .emerald: .green,
        .diamond: .blue,
        .master: .purple,
        .grandmaster: .red,
        .challenger: .orange
    ]
    
    // MARK: - Achievement Icons
    static let achievementIcons: [String: String] = [
        "first_run": "figure.run",
        "10k_total": "10.circle.fill",
        "50k_total": "50.circle.fill",
        "100k_total": "100.circle.fill",
        "marathon": "medal.fill",
        "streak_7": "flame.fill",
        "streak_30": "flame.fill",
        "early_bird": "sunrise.fill",
        "night_owl": "moon.stars.fill"
    ]
    
    // MARK: - Default Values
    static let defaultTargetWeeklyRuns = 3
    static let defaultTargetWeeklyDistance = 15.0 // km
    static let minRunDistance = 0.5 // km
    static let minRunDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - HealthKit Analysis
    static let analysisMonths = 3
    static let maxWorkoutsToAnalyze = 100
    
    // MARK: - Tier System
    static let lpPerGrade = 200
    static let gradesPerTier = 4
    
    // MARK: - Formatting
    static let distanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let paceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    // MARK: - Date Formatters
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}
