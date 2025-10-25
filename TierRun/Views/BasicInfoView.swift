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
                    TextField("Name", text: $name)
                        .textContentType(.name)
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    Picker("Gender", selection: $selectedGender) {
                        Text("Male").tag(Gender.male)
                        Text("Female").tag(Gender.female)
                        Text("Other").tag(Gender.other)
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Physical Profile")
                } footer: {
                    Text("This helps us calculate LP fairly based on your profile")
                }
                
                Section {
                    Picker("Running Experience", selection: $selectedExperience) {
                        Text("Beginner (< 6 months)").tag(Experience.beginner)
                        Text("Intermediate (6m - 2y)").tag(Experience.intermediate)
                        Text("Advanced (2y - 5y)").tag(Experience.advanced)
                        Text("Elite (5y+)").tag(Experience.elite)
                    }
                } header: {
                    Text("Experience Level")
                }
                
                Section {
                    Button {
                        saveAndContinue()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Continue to Placement Test")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("About You")
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveAndContinue() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight) else {
            errorMessage = "Please enter valid age and weight"
            showingError = true
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
            errorMessage = "Failed to save data: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    BasicInfoView(onContinue: {})
        .modelContainer(for: [User.self, Tier.self], inMemory: true)
}
