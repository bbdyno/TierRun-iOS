//
//  TierSystemInfoView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct TierSystemInfoView: View {
    
    let tiers: [TierLevel] = TierLevel.allCases
    
    var body: some View {
        List {
            Section {
                Text(L10n.TierInfo.intro)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text(L10n.TierInfo.howItWorks)
            }
            
            Section {
                ForEach(tiers, id: \.self) { tier in
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(getTierColor(tier))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tier.rawValue.capitalized)
                                .font(.headline)
                            
                            Text("\(tier.baseLP) - \(tier.baseLP + 799) LP")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if tier == .challenger {
                            Text(L10n.TierInfo.topPercent)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text(L10n.TierInfo.tierRanks)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.TierInfo.earnLP)
                    Text(L10n.TierInfo.lpCalculation)
                    Text(L10n.TierInfo.distancePace)
                    Text(L10n.TierInfo.heartRate)
                    Text(L10n.TierInfo.consistency)
                    Text(L10n.TierInfo.reachThreshold)
                    Text(L10n.TierInfo.completeChallenges)
                }
                .font(.subheadline)
            } header: {
                Text(L10n.TierInfo.howToRankUp)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.TierInfo.aiAdjusts)
                    Text(L10n.TierInfo.personalImprovement)
                    Text(L10n.TierInfo.healthyTraining)
                    Text(L10n.TierInfo.restDays)
                }
                .font(.subheadline)
            } header: {
                Text(L10n.TierInfo.fairPlay)
            }
        }
        .navigationTitle(L10n.Tier.title)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func getTierColor(_ tier: TierLevel) -> Color {
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
}

#Preview {
    NavigationStack {
        TierSystemInfoView()
    }
}
