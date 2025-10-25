//
//  ConditionCardView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct ConditionCardView: View {
    
    let score: Int
    let sleepHours: Double
    let restingHeartRate: Int
    
    var scoreColor: Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .yellow
        } else {
            return .orange
        }
    }
    
    var recommendation: String {
        if score >= 80 {
            return "Great condition! Perfect day for running 🏃‍♂️"
        } else if score >= 60 {
            return "Good condition. Easy run recommended."
        } else {
            return "Consider taking a rest day today 😴"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Condition")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 20) {
                // Score
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor)
                        
                        Text("/100")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Data points
                VStack(alignment: .trailing, spacing: 12) {
                    DataPoint(
                        icon: "moon.fill",
                        value: String(format: "%.1fh", sleepHours),
                        label: "Sleep"
                    )
                    
                    DataPoint(
                        icon: "heart.fill",
                        value: "\(restingHeartRate)",
                        label: "Resting HR"
                    )
                }
            }
            
            // Recommendation
            Text(recommendation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct DataPoint: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ConditionCardView(
        score: 85,
        sleepHours: 7.5,
        restingHeartRate: 58
    )
    .padding()
}
