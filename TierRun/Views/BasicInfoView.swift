//
//  BasicInfoView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct BasicInfoView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let onContinue: () -> Void
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedExperience: Experience = .beginner
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isFormValid: Bool {
        !name.isEmpty &&
        Int(age) != nil &&
        Double(weight) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.BasicInfo.name, text: $name)
                        .textContentType(.name)
                } header: {
                    Text(L10n.BasicInfo.basicInformation)
                }
                
                Section {
                    Picker(L10n.BasicInfo.gender, selection: $selectedGender) {
                        Text(L10n.BasicInfo.male).tag(Gender.male)
                        Text(L10n.BasicInfo.female).tag(Gender.female)
                        Text(L10n.BasicInfo.other).tag(Gender.other)
                    }

                    TextField(L10n.BasicInfo.age, text: $age)
                        .keyboardType(.numberPad)

                    HStack {
                        TextField(L10n.BasicInfo.weight, text: $weight)
                            .keyboardType(.decimalPad)
                        Text(L10n.Unit.kg)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(L10n.BasicInfo.physicalProfile)
                } footer: {
                    Text(L10n.BasicInfo.profileDescription)
                }
                
                Section {
                    Picker(L10n.BasicInfo.runningExperience, selection: $selectedExperience) {
                        Text(L10n.BasicInfo.beginner).tag(Experience.beginner)
                        Text(L10n.BasicInfo.intermediate).tag(Experience.intermediate)
                        Text(L10n.BasicInfo.advanced).tag(Experience.advanced)
                        Text(L10n.BasicInfo.elite).tag(Experience.elite)
                    }
                } header: {
                    Text(L10n.BasicInfo.experienceLevel)
                }
                
                Section {
                    Button {
                        saveAndContinue()
                    } label: {
                        HStack {
                            Spacer()
                            Text(L10n.BasicInfo.continue)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(L10n.BasicInfo.title)
            .alert(L10n.Common.error, isPresented: $showingError) {
                Button(L10n.Common.ok, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveAndContinue() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight) else {
            errorMessage = L10n.BasicInfo.invalidInput            showingError = true
            return
        }
        
        // Create user
        let user = User(
            name: name,
            age: ageInt,
            gender: selectedGender,
            weight: weightDouble,
            experience: selectedExperience,
            mainRole: .marathoner // Will be determined in placement test
        )
        
        // Create initial tiers
        let marathonerTier = Tier(role: .marathoner)
        let sprinterTier = Tier(role: .sprinter)
        
        user.marathonerTier = marathonerTier
        user.sprinterTier = sprinterTier
        marathonerTier.user = user
        sprinterTier.user = user
        
        // Save to SwiftData
        modelContext.insert(user)
        modelContext.insert(marathonerTier)
        modelContext.insert(sprinterTier)
        
        do {
            try modelContext.save()
            onContinue()
        } catch {
            errorMessage = "Failed to save data: \(errorDescription)"
            showingError = true
        }
    }
}

#Preview {
    BasicInfoView(onContinue: {})
        .modelContainer(for: [User.self, Tier.self], inMemory: true)
}
