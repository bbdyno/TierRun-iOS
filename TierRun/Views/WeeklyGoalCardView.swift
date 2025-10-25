//
//  WeeklyGoalCardView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct WeeklyGoalCardView: View {
    
    let progress: WeeklyProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Goal")
                .font(.headline)
            
            // Progress
            HStack {
                Text("\(progress.completedRuns) / \(progress.targetRuns) runs")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            ProgressView(value: progress.progress)
                .tint(.blue)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            // Stats
            HStack(spacing: 20) {
                WeeklyStatItem(
                    value: String(format: "%.1f km", progress.totalDistance),
                    label: "Distance"
                )
                
                Spacer()
                
                WeeklyStatItem(
                    value: "+\(progress.totalLP) LP",
                    label: "This Week"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct WeeklyStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WeeklyGoalCardView(
        progress: WeeklyProgress(
            completedRuns: 2,
            targetRuns: 3,
            totalDistance: 15.5,
            totalLP: 50
        )
    )
    .padding()
}
