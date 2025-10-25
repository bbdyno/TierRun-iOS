//
//  TierBadgeView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct TierBadgeView: View {
    
    let tier: Tier
    let rankPercentage: Double
    
    var tierColor: Color {
        switch tier.currentTier {
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
        VStack(spacing: 20) {
            // Tier Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tierColor.opacity(0.3), tierColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(tierColor)
                    
                    Text(tier.currentTier.rawValue.capitalized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(tier.currentGrade)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // LP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("\(tier.lp) LP")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(tier.nextTierLP) LP")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: tier.progressToNextTier)
                    .tint(tierColor)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text("Top \(String(format: "%.1f", rankPercentage))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
}

#Preview {
    TierBadgeView(
        tier: Tier(
            role: .marathoner,
            currentTier: .gold,
            currentGrade: 2,
            lp: 2650
        ),
        rankPercentage: 35.5
    )
    .padding()
}
