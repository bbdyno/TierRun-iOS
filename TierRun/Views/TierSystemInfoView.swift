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
                Text("The tier system ranks your running performance across two roles: Marathoner and Sprinter.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text("How It Works")
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
                            Text("Top 0.1%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Tier Ranks")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Complete runs to earn LP")
                    Text("• LP is calculated based on:")
                    Text("  - Distance and pace")
                    Text("  - Heart rate management")
                    Text("  - Consistency")
                    Text("• Reach the next tier's LP threshold")
                    Text("• Complete promotion challenges")
                }
                .font(.subheadline)
            } header: {
                Text("How to Rank Up")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• AI adjusts for age, gender, and experience")
                    Text("• Focus on personal improvement, not just speed")
                    Text("• Healthy training is rewarded")
                    Text("• Rest days don't lower your LP")
                }
                .font(.subheadline)
            } header: {
                Text("Fair Play")
            }
        }
        .navigationTitle("Tier System")
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
