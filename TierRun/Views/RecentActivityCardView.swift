//
//  RecentActivityCardView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct RecentActivityCardView: View {
    
    let run: Run
    
    var roleIcon: String {
        run.role == .marathoner ? "figure.run" : "bolt.fill"
    }
    
    var roleColor: Color {
        run.role == .marathoner ? .blue : .red
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Role Icon
            Image(systemName: roleIcon)
                .font(.title2)
                .foregroundStyle(roleColor)
                .frame(width: 40, height: 40)
                .background(roleColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(run.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let source = run.sourceApp {
                        Text("• \(source)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Text(String(format: "%.2f km", run.distance))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    Label(run.formattedDuration, systemImage: "clock")
                    Label(run.formattedPace, systemImage: "speedometer")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(run.lpEarned) LP")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    RecentActivityCardView(
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
    .padding()
}
