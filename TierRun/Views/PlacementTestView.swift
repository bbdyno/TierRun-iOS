//
//  PlacementTestView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct PlacementTestView: View {
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var currentStep: PlacementStep = .welcome
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    @State private var placementResult: PlacementResult?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            switch currentStep {
            case .welcome:
                placementWelcomeView
            case .requestingPermission:
                permissionRequestView
            case .analyzing:
                analyzingView
            case .result:
                if let result = placementResult {
                    placementResultView(result: result)
                }
            }
        }
        .alert(L10n.Common.error, isPresented: $showingError) {
            Button(L10n.Common.ok, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var placementWelcomeView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
            
            VStack(spacing: 16) {
                Text(L10n.Placement.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(L10n.Placement.subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                PlacementStepRow(
                    number: 1,
                    text: L10n.Placement.step1                )

                PlacementStepRow(
                    number: 2,
                    text: L10n.Placement.step2                )

                PlacementStepRow(
                    number: 3,
                    text: L10n.Placement.step3                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                startPlacementTest()
            } label: {
                Text(L10n.Placement.startTest)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
    
    private var permissionRequestView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ProgressView()
                .scaleEffect(2)
            
            Text(L10n.Placement.requestingPermission)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    private var analyzingView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                ProgressView(value: analysisProgress)
                    .scaleEffect(x: 1, y: 2)
                    .tint(.blue)
                    .frame(width: 200)
                
                Text("\(Int(analysisProgress * 100))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            
            VStack(spacing: 8) {
                Text(L10n.Placement.analyzingData)
                    .font(.headline)

                Text(getAnalysisMessage())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func placementResultView(result: PlacementResult) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                Text(L10n.Placement.complete)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // Marathoner Tier
                TierResultCard(
                    role: L10n.Role.marathoner,
                    tier: result.marathonerTier,
                    grade: result.marathonerGrade,
                    analysis: result.marathonerAnalysis
                )

                // Sprinter Tier
                TierResultCard(
                    role: L10n.Role.sprinter,
                    tier: result.sprinterTier,
                    grade: result.sprinterGrade,
                    analysis: result.sprinterAnalysis
                )
                
                // Recommendation
                VStack(spacing: 12) {
                    Text(L10n.Placement.recommendedRole)
                        .font(.headline)

                    HStack {
                        Image(systemName: result.recommendedRole == .marathoner ? "figure.run" : "bolt.fill")
                            .font(.title)

                        Text(result.recommendedRole == .marathoner ? L10n.Role.marathoner : L10n.Role.sprinter)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button {
                    completeOnboarding(result: result)
                } label: {
                    Text(L10n.Placement.getStarted)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func startPlacementTest() {
        currentStep = .requestingPermission
        
        Task {
            do {
                // Request HealthKit permission
                try await HealthKitManager.shared.requestAuthorization()
                
                await MainActor.run {
                    currentStep = .analyzing
                }
                
                // Simulate analysis progress
                for i in 1...10 {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    await MainActor.run {
                        analysisProgress = Double(i) / 10.0
                    }
                }
                
                // Perform actual analysis
                let result = try await performPlacementAnalysis()
                
                await MainActor.run {
                    placementResult = result
                    currentStep = .result
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to complete placement test: \(errorDescription)"
                    showingError = true
                    currentStep = .welcome
                }
            }
        }
    }
    
    private func performPlacementAnalysis() async throws -> PlacementResult {
        // Fetch past 3 months of workouts
        let workouts = try await HealthKitManager.shared.fetchRecentWorkouts(months: 3)
        
        // Get user
        let descriptor = FetchDescriptor<User>()
        guard let user = try? modelContext.fetch(descriptor).first else {
            throw PlacementError.userNotFound
        }
        
        // Analyze marathoner performance
        let marathonerWorkouts = workouts.filter { $0.role == .marathoner }
        let (marathonerTier, marathonerGrade) = TierCalculator.calculateInitialTier(
            workouts: marathonerWorkouts,
            user: user
        )
        
        // Analyze sprinter performance
        let sprinterWorkouts = workouts.filter { $0.role == .sprinter }
        let (sprinterTier, sprinterGrade) = TierCalculator.calculateInitialTier(
            workouts: sprinterWorkouts,
            user: user
        )
        
        // Determine recommended role
        let recommendedRole: RunRole = marathonerWorkouts.count > sprinterWorkouts.count ? .marathoner : .sprinter
        
        return PlacementResult(
            marathonerTier: marathonerTier,
            marathonerGrade: marathonerGrade,
            marathonerAnalysis: generateAnalysis(tier: marathonerTier, workouts: marathonerWorkouts),
            sprinterTier: sprinterTier,
            sprinterGrade: sprinterGrade,
            sprinterAnalysis: generateAnalysis(tier: sprinterTier, workouts: sprinterWorkouts),
            recommendedRole: recommendedRole
        )
    }
    
    private func generateAnalysis(tier: TierLevel, workouts: [WorkoutData]) -> String {
        if workouts.isEmpty {
            return "No recent data found. You'll start in \(tier.rawValue.capitalized) tier."
        }
        
        let avgDistance = workouts.reduce(0.0) { $0 + $1.distance } / Double(workouts.count)
        return "Based on \(workouts.count) runs with average distance of \(String(format: "%.1f", avgDistance)) km"
    }
    
    private func completeOnboarding(result: PlacementResult) {
        // Update user's tiers
        let descriptor = FetchDescriptor<User>()
        guard let user = try? modelContext.fetch(descriptor).first else { return }
        
        user.mainRole = result.recommendedRole
        
        if let marathonerTier = user.marathonerTier {
            marathonerTier.currentTier = result.marathonerTier
            marathonerTier.currentGrade = result.marathonerGrade
            marathonerTier.lp = result.marathonerTier.baseLP + (4 - result.marathonerGrade) * 200
        }
        
        if let sprinterTier = user.sprinterTier {
            sprinterTier.currentTier = result.sprinterTier
            sprinterTier.currentGrade = result.sprinterGrade
            sprinterTier.lp = result.sprinterTier.baseLP + (4 - result.sprinterGrade) * 200
        }
        
        try? modelContext.save()
        
        hasCompletedOnboarding = true
    }
    
    private func getAnalysisMessage() -> String {
        let progress = analysisProgress

        if progress < 0.3 {
            return L10n.Placement.fetchingHistory        } else if progress < 0.6 {
            return L10n.Placement.analyzingPatterns        } else if progress < 0.9 {
            return L10n.Placement.calculatingPlacement        } else {
            return L10n.Placement.almostDone        }
    }
}

struct PlacementStepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct TierResultCard: View {
    let role: String
    let tier: TierLevel
    let grade: Int
    let analysis: String
    
    var tierColor: Color {
        switch tier {
        case .iron: return .gray
        case .bronze: return .brown
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return .yellow
        case .platinum: return .cyan
        case .emerald: return .green
        case .diamond: return .blue
        case .master: return .purple
        case .grandmaster: return .red
        case .challenger: return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(role)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundStyle(tierColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(L10n.Tier.grade(grade))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(analysis)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

enum PlacementStep {
    case welcome
    case requestingPermission
    case analyzing
    case result
}

struct PlacementResult {
    let marathonerTier: TierLevel
    let marathonerGrade: Int
    let marathonerAnalysis: String
    let sprinterTier: TierLevel
    let sprinterGrade: Int
    let sprinterAnalysis: String
    let recommendedRole: RunRole
}

enum PlacementError: Error {
    case userNotFound
    case noData
}

#Preview {
    PlacementTestView()
        .modelContainer(for: [User.self, Tier.self], inMemory: true)
}
