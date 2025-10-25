//
//  TierView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct TierView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TierViewModel?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Role Picker
                    if let vm = viewModel {
                        rolePicker(vm: vm)
                    }
                    
                    // Current Tier Card
                    if let tier = viewModel?.currentTier {
                        TierBadgeView(tier: tier, rankPercentage: viewModel?.getRankPercentage() ?? 50)
                    }
                    
                    // Stats
                    if let stats = viewModel?.getTierStats() {
                        tierStatsView(stats: stats)
                    }
                    
                    // Actions
                    actionButtons
                    
                    // Tier History
                    if let history = viewModel?.currentTier?.tierHistory {
                        tierHistoryView(history: history)
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.Tier.title)
            .onAppear {
                if viewModel == nil {
                    viewModel = TierViewModel(modelContext: modelContext)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.isShowingCertificateGenerator ?? false },
                set: { viewModel?.isShowingCertificateGenerator = $0 }
            )) {
                if let tier = viewModel?.currentTier {
                    CertificateGeneratorView(tier: tier)
                }
            }
        }
    }
    
    private func rolePicker(vm: TierViewModel) -> some View {
        Picker(L10n.Role.title, selection: Binding(
            get: { vm.selectedRole },
            set: { _ in vm.switchRole() }
        )) {
            Text(L10n.Role.marathoner).tag(RunRole.marathoner)
            Text(L10n.Role.sprinter).tag(RunRole.sprinter)
        }
        .pickerStyle(.segmented)
    }
    
    private func tierStatsView(stats: TierStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tier.lpStats)
                .font(.headline)

            HStack(spacing: 16) {
                StatBox(title: L10n.Tier.thisWeek, value: "+\(stats.weeklyLP) LP")
                StatBox(title: L10n.Tier.thisMonth, value: "+\(stats.monthlyLP) LP")
                StatBox(title: L10n.Tier.thisSeason, value: "+\(stats.seasonLP) LP")
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel?.isShowingCertificateGenerator = true
            } label: {
                HStack {
                    Image(systemName: "rosette")
                    Text(L10n.Tier.createCertificate)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }

            NavigationLink(destination: TierSystemInfoView()) {
                HStack {
                    Image(systemName: "info.circle")
                    Text(L10n.Tier.learnMore)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func tierHistoryView(history: [TierHistoryEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tier.history)
                .font(.headline)

            if history.isEmpty {
                Text(L10n.Tier.noHistory)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(history.indices, id: \.self) { index in
                    let entry = history[index]
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.tier.rawValue.capitalized) \(entry.grade)")
                                .font(.headline)
                            
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(entry.lp) LP")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    TierView()
        .modelContainer(for: [User.self, Tier.self], inMemory: true)
}
