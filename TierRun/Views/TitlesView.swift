//
//  TitlesView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct TitlesView: View {
    
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var unlockedTitles: [Title] {
        viewModel.titles.filter { $0.isUnlocked }
    }
    
    var lockedTitles: [Title] {
        viewModel.titles.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if let equipped = viewModel.equippedTitle {
                    Section {
                        TitleRow(title: equipped, isEquipped: true)
                        
                        Button(role: .destructive) {
                            viewModel.unequipTitle()
                        } label: {
                            Text("Unequip Title")
                                .frame(maxWidth: .infinity)
                        }
                    } header: {
                        Text("Equipped")
                    }
                }
                
                if !unlockedTitles.isEmpty {
                    Section {
                        ForEach(unlockedTitles) { title in
                            if title.id != viewModel.equippedTitle?.id {
                                TitleRow(title: title, isEquipped: false)
                                    .onTapGesture {
                                        viewModel.equipTitle(title)
                                    }
                            }
                        }
                    } header: {
                        Text("Unlocked Titles")
                    }
                }
                
                if !lockedTitles.isEmpty {
                    Section {
                        ForEach(lockedTitles) { title in
                            TitleRow(title: title, isEquipped: false)
                                .opacity(0.5)
                        }
                    } header: {
                        Text("Locked Titles")
                    }
                }
            }
            .navigationTitle("Titles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TitleRow: View {
    
    let title: Title
    let isEquipped: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundStyle(title.rarity.color)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title.name)
                        .font(.headline)
                    
                    if isEquipped {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                
                Text(title.titleDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !title.isUnlocked {
                    Text("Requirement: \(title.requirement)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            if title.isUnlocked && !isEquipped {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TitlesView(
        viewModel: ProfileViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: User.self, Title.self)
            )
        )
    )
}
