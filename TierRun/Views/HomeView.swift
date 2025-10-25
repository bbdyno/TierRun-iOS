//
//  HomeView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Condition Card
                    if let vm = viewModel {
                        ConditionCardView(
                            score: vm.conditionScore,
                            sleepHours: vm.sleepHours,
                            restingHeartRate: vm.restingHeartRate
                        )
                    }
                    
                    // Weekly Goal
                    if let progress = viewModel?.weeklyProgress {
                        WeeklyGoalCardView(progress: progress)
                    }
                    
                    // Recent Activities
                    recentActivitiesSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle(L10n.Home.title)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel == nil {
                    viewModel = HomeViewModel(modelContext: modelContext)
                }
            }
            .refreshable {
                viewModel?.syncHealthKit()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let lastSync = viewModel?.lastSyncDate {
                    Text(L10n.Home.lastSync(lastSync.formatted(date: .omitted, time: .shortened)))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Button {
                viewModel?.syncHealthKit()
            } label: {
                if viewModel?.isSyncing == true {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                }
            }
            .disabled(viewModel?.isSyncing == true)
        }
    }
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Home.recentActivities)
                .font(.title2)
                .fontWeight(.bold)

            if let runs = viewModel?.recentRuns, !runs.isEmpty {
                ForEach(runs) { run in
                    NavigationLink(destination: ActivityDetailView(run: run)) {
                        RecentActivityCardView(run: run)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ContentUnavailableView(
                    L10n.Home.noActivities,
                    systemImage: "figure.run",
                    description: Text(L10n.Home.NoActivities.description)
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: CertificateGeneratorView()) {
                HStack {
                    Image(systemName: "rosette")
                    Text(L10n.Home.createCertificate)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }

            NavigationLink(destination: Text("Weekly Highlights")) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text(L10n.Home.weeklyHighlights)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [User.self, Run.self], inMemory: true)
}
