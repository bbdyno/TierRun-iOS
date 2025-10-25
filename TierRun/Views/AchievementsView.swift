//
//  AchievementsView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct AchievementsView: View {
    
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: AchievementCategory = .distance
    
    var filteredAchievements: [Achievement] {
        viewModel.achievements.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                Picker(L10n.Achievements.category, selection: $selectedCategory) {
                    ForEach([AchievementCategory.distance, .frequency, .streak, .speed, .special], id: \.self) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Achievements List
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.Achievements.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementCard: View {
    
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.rarity.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(achievement.isUnlocked ? achievement.rarity.color : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .tint(achievement.rarity.color)
                    .scaleEffect(x: 1, y: 0.5)


                Text(L10n.Achievements.progress(Int(achievement.progress * 100)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else if let date = achievement.unlockedAt {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

extension AchievementRarity {
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

#Preview {
    AchievementsView(
        viewModel: ProfileViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: User.self, Achievement.self)
            )
        )
    )
}
