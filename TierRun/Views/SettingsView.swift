//
//  SettingsView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useMetric") private var useMetric = true
    @AppStorage("language") private var language = "en"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoSync") private var autoSync = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Metric Units (km)", isOn: $useMetric)
                } header: {
                    Text("Units")
                } footer: {
                    Text(useMetric ? "Distance will be shown in kilometers" : "Distance will be shown in miles")
                }
                
                Section {
                    Picker("Language", selection: $language) {
                        Text("English").tag("en")
                        Text("한국어").tag("ko")
                        Text("日本語").tag("ja")
                    }
                } header: {
                    Text("Localization")
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Auto Sync HealthKit", isOn: $autoSync)
                } header: {
                    Text("App Behavior")
                } footer: {
                    Text("Auto sync will check for new workouts daily")
                }
                
                Section {
                    NavigationLink("HealthKit Permissions") {
                        HealthKitPermissionsView()
                    }
                } header: {
                    Text("HealthKit")
                }
                
                Section {
                    Button("Export All Data") {
                        exportData()
                    }
                    
                    Button("Reset Placement Test", role: .destructive) {
                        resetPlacementTest()
                    }
                    
                    Button("Delete All Data", role: .destructive) {
                        deleteAllData()
                    }
                } header: {
                    Text("Data Management")
                }
            }
            .navigationTitle("Settings")
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
    
    private func exportData() {
        // TODO: Implement data export
        print("Export data")
    }
    
    private func resetPlacementTest() {
        // TODO: Implement reset
        print("Reset placement test")
    }
    
    private func deleteAllData() {
        // TODO: Implement delete with confirmation
        print("Delete all data")
    }
}

struct HealthKitPermissionsView: View {
    
    @State private var hasWorkoutPermission = false
    @State private var hasHeartRatePermission = false
    @State private var hasSleepPermission = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Workout Data")
                    Spacer()
                    Image(systemName: hasWorkoutPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasWorkoutPermission ? .green : .red)
                }
                
                HStack {
                    Text("Heart Rate")
                    Spacer()
                    Image(systemName: hasHeartRatePermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasHeartRatePermission ? .green : .red)
                }
                
                HStack {
                    Text("Sleep Analysis")
                    Spacer()
                    Image(systemName: hasSleepPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasSleepPermission ? .green : .red)
                }
            } header: {
                Text("Permissions Status")
            }
            
            Section {
                Button("Open Health App") {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }
            } footer: {
                Text("You can manage HealthKit permissions in the Health app under Sources.")
            }
        }
        .navigationTitle("HealthKit")
        .onAppear {
            checkPermissions()
        }
    }
    
    private func checkPermissions() {
        // TODO: Check actual HealthKit permissions
        hasWorkoutPermission = true
        hasHeartRatePermission = true
        hasSleepPermission = true
    }
}

#Preview {
    SettingsView()
}
