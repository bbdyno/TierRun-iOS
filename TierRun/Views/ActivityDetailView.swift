//
//  ActivityDetailView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import MapKit
import SwiftData

struct ActivityDetailView: View {
    
    let run: Run
    @Environment(\.modelContext) private var modelContext
    @State private var showingReclassifyAlert = false
    
    var roleColor: Color {
        run.role == .marathoner ? .blue : .red
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Main Stats
                mainStatsSection
                
                // Map (if available)
                if !run.route.isEmpty {
                    mapSection
                }
                
                // Heart Rate Analysis
                heartRateSection
                
                // Splits
                if !run.splits.isEmpty {
                    splitsSection
                }
                
                // Additional Data
                additionalDataSection
                
                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Run Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reclassify Run", isPresented: $showingReclassifyAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reclassify") {
                reclassifyRun()
            }
        } message: {
            Text("Change this run to \(run.role == .marathoner ? "Sprinter" : "Marathoner")? LP will be recalculated.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: run.role == .marathoner ? "figure.run" : "bolt.fill")
                    .font(.title3)
                    .foregroundStyle(roleColor)
                
                Text(run.role == .marathoner ? "Marathoner" : "Sprinter")
                    .font(.headline)
                    .foregroundStyle(roleColor)
                
                if let source = run.sourceApp {
                    Spacer()
                    Text(source)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(run.date.formatted(date: .complete, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var mainStatsSection: some View {
        VStack(spacing: 16) {
            // Distance
            VStack(spacing: 4) {
                Text(String(format: "%.2f", run.distance))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                
                Text("km")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            // Time & Pace
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text(run.formattedDuration)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(run.formattedPace)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Pace")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // LP Badge
            HStack {
                Spacer()
                Text("+\(run.lpEarned) LP")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Route")
                .font(.headline)
            
            Map(initialPosition: .automatic) {
                // Draw route
                if run.route.count > 1 {
                    MapPolyline(coordinates: run.route.map { location in
                        CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    })
                    .stroke(.blue, lineWidth: 4)
                }
                
                // Start marker
                if let first = run.route.first {
                    Annotation("Start", coordinate: CLLocationCoordinate2D(
                        latitude: first.latitude,
                        longitude: first.longitude
                    )) {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // End marker
                if let last = run.route.last {
                    Annotation("End", coordinate: CLLocationCoordinate2D(
                        latitude: last.latitude,
                        longitude: last.longitude
                    )) {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
        }
    }
    
    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heart Rate")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(run.averageHeartRate) bpm")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Maximum")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(run.maxHeartRate) bpm")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            // Heart Rate Zones
            if !run.heartRateZones.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time in Zones")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(run.heartRateZones.keys.sorted()), id: \.self) { zone in
                        if let time = run.heartRateZones[zone] {
                            HStack {
                                Text("Zone \(zone)")
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(formatDuration(time))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Splits")
                .font(.headline)
            
            ForEach(Array(run.splits.enumerated()), id: \.offset) { index, split in
                HStack {
                    Text("km \(index + 1)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)
                    
                    Text(formatDuration(split.time))
                        .font(.subheadline)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(String(format: "%.0f'%.0f\"", split.pace.truncatingRemainder(dividingBy: 60), split.pace.remainder(dividingBy: 1) * 60))
                        .font(.subheadline)
                        .monospacedDigit()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var additionalDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Data")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DataItem(
                    icon: "flame.fill",
                    label: "Calories",
                    value: "\(run.calories)"
                )
                
                DataItem(
                    icon: "figure.run",
                    label: "Cadence",
                    value: "\(run.cadence) spm"
                )
                
                DataItem(
                    icon: "arrow.up.right",
                    label: "Elevation",
                    value: String(format: "%.0f m", run.elevationGain)
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingReclassifyAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Reclassify as \(run.role == .marathoner ? "Sprinter" : "Marathoner")")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            ShareLink(item: generateShareText()) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func reclassifyRun() {
        let newRole: RunRole = run.role == .marathoner ? .sprinter : .marathoner
        
        // Update role
        let oldRole = run.role
        run.role = newRole
        
        // Recalculate LP
        let oldLP = run.lpEarned
        
        var descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            run.lpEarned = TierCalculator.calculateLP(for: run, user: user)
            
            // Update tier LP
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
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func generateShareText() -> String {
        return """
        I just completed a \(String(format: "%.2f", run.distance)) km run! 🏃‍♂️
        Time: \(run.formattedDuration)
        Pace: \(run.formattedPace) /km
        +\(run.lpEarned) LP earned!
        """
    }
}

struct DataItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ActivityDetailView(
            run: Run(
                date: Date(),
                role: .marathoner,
                distance: 5.2,
                duration: 1800,
                averagePace: 5.77,
                averageHeartRate: 150,
                maxHeartRate: 175,
                calories: 450,
                lpEarned: 25,
                sourceApp: "Apple Watch"
            )
        )
    }
    .modelContainer(for: [Run.self], inMemory: true)
}
