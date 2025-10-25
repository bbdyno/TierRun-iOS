//
//  ProfileView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ProfileView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProfileViewModel?
    @State private var showingCertificateGenerator = false
    @State private var showingAchievements = false
    @State private var showingTitles = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                if let user = viewModel?.user {
                    profileHeaderSection(user: user)
                }
                
                // Tier Badges
                tierBadgesSection
                
                // Stats
                statsSection
                
                // Certificate
                certificateSection
                
                // Achievements & Titles
                achievementsSection
                
                // Donation
                donationSection
                
                // Settings
                settingsSection
                
                // Info
                infoSection
            }
            .navigationTitle(L10n.Profile.title)
            .onAppear {
                if viewModel == nil {
                    viewModel = ProfileViewModel(modelContext: modelContext)
                }
            }
            .sheet(isPresented: $showingCertificateGenerator) {
                if let tier = viewModel?.user?.marathonerTier {
                    CertificateGeneratorView(tier: tier)
                }
            }
            .sheet(isPresented: $showingAchievements) {
                if let vm = viewModel {
                    AchievementsView(viewModel: vm)
                }
            }
            .sheet(isPresented: $showingTitles) {
                if let vm = viewModel {
                    TitlesView(viewModel: vm)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private func profileHeaderSection(user: User) -> some View {
        Section {
            VStack(spacing: 16) {
                // Profile Image Placeholder
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                    }
                
                // Name
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Equipped Title
                if let title = viewModel?.equippedTitle {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(title.rarity.color)
                            .font(.caption)
                        
                        Text(title.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }
    
    private var tierBadgesSection: some View {
        Section {
            HStack(spacing: 20) {
                if let marathonerTier = viewModel?.user?.marathonerTier {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        Text(marathonerTier.tierName)
                            .font(.headline)
                        
                        Text(L10n.Role.marathoner)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if let sprinterTier = viewModel?.user?.sprinterTier {
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                        
                        Text(sprinterTier.tierName)
                            .font(.headline)
                        
                        Text(L10n.Role.sprinter)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Profile.tiers)
        }
    }
    
    private var statsSection: some View {
        Section {
            if let stats = viewModel?.getTotalStats() {
                HStack {
                    StatItem(
                        icon: "figure.run",
                        value: "\(stats.totalRuns)",
                        label: L10n.Profile.totalRuns                    )

                    Divider()

                    StatItem(
                        icon: "map",
                        value: String(format: "%.1f km", stats.totalDistance),
                        label: L10n.Profile.totalDistance                    )

                    Divider()

                    StatItem(
                        icon: "star.fill",
                        value: "\(stats.totalLP)",
                        label: L10n.Profile.totalLP                    )
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text(L10n.Profile.statistics)
        }
    }
    
    private var certificateSection: some View {
        Section {
            Button {
                showingCertificateGenerator = true
            } label: {
                HStack {
                    Image(systemName: "rosette")
                        .foregroundStyle(.blue)
                    
                    Text(L10n.Profile.createCertificate)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text(L10n.Profile.certificate)
        }
    }
    
    private var achievementsSection: some View {
        Section {
            Button {
                showingAchievements = true
            } label: {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Profile.achievements)

                        if let unlocked = viewModel?.getUnlockedAchievements().count,
                           let total = viewModel?.achievements.count {
                            Text(L10n.Profile.achievementsProgress(unlocked, total))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button {
                showingTitles = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.purple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Profile.titles)

                        if let unlocked = viewModel?.getUnlockedTitles().count,
                           let total = viewModel?.titles.count {
                            Text(L10n.Profile.achievementsProgress(unlocked, total))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text(L10n.Profile.progression)
        }
    }
    
    private var donationSection: some View {
        Section {
            NavigationLink(destination: DonationView()) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    
                    Text(L10n.Profile.supportDeveloper)
                }
            }
        } header: {
            Text(L10n.Profile.support)
        } footer: {
            Text(L10n.Profile.supportMessage)
        }
    }
    
    private var settingsSection: some View {
        Section {
            Button {
                showingSettings = true
            } label: {
                HStack {
                    Image(systemName: "gear")
                        .foregroundStyle(.gray)
                    
                    Text(L10n.Profile.settings)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var infoSection: some View {
        Section {
            Link(destination: URL(string: "https://tierrun.app/terms")!) {
                HStack {
                    Text(L10n.Profile.termsOfService)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Link(destination: URL(string: "https://tierrun.app/privacy")!) {
                HStack {
                    Text(L10n.Profile.privacyPolicy)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                Text(L10n.Profile.version)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(L10n.Profile.about)
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self, Achievement.self, Title.self], inMemory: true)
}
