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
                    Toggle(L10n.Settings.metricUnits, isOn: $useMetric)
                } header: {
                    Text(L10n.Settings.units)
                } footer: {
                    Text(useMetric ? L10n.Settings.metricDescription : L10n.Settings.imperialDescription)
                }
                
                Section {
                    Picker(L10n.Settings.localization, selection: $language) {
                        Text(L10n.Settings.english).tag("en")
                        Text(L10n.Settings.korean).tag("ko")
                        Text(L10n.Settings.japanese).tag("ja")
                    }
                } header: {
                    Text(L10n.Settings.localization)
                }
                
                Section {
                    Toggle(L10n.Settings.enableNotifications, isOn: $notificationsEnabled)
                    Toggle(L10n.Settings.autoSyncHealthKit, isOn: $autoSync)
                } header: {
                    Text(L10n.Settings.appBehavior)
                } footer: {
                    Text(L10n.Settings.autoSyncDescription)
                }
                
                Section {
                    NavigationLink(L10n.Settings.healthKitPermissions) {
                        HealthKitPermissionsView()
                    }
                } header: {
                    Text(L10n.Settings.healthKit)
                }
                
                Section {
                    Button(L10n.Settings.exportData) {
                        exportData()
                    }

                    Button(L10n.Settings.resetPlacementTest, role: .destructive) {
                        resetPlacementTest()
                    }

                    Button(L10n.Settings.deleteAllData, role: .destructive) {
                        deleteAllData()
                    }
                } header: {
                    Text(L10n.Settings.dataManagement)
                }
            }
            .navigationTitle(L10n.Settings.title)
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
                    Text(L10n.Settings.workoutData)
                    Spacer()
                    Image(systemName: hasWorkoutPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasWorkoutPermission ? .green : .red)
                }

                HStack {
                    Text(L10n.Settings.heartRate)
                    Spacer()
                    Image(systemName: hasHeartRatePermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasHeartRatePermission ? .green : .red)
                }

                HStack {
                    Text(L10n.Settings.sleepAnalysis)
                    Spacer()
                    Image(systemName: hasSleepPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(hasSleepPermission ? .green : .red)
                }
            } header: {
                Text(L10n.Settings.permissionsStatus)
            }
            
            Section {
                Button(L10n.Settings.openHealthApp) {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }
            } footer: {
                Text(L10n.Settings.healthAppMessage)
            }
        }
        .navigationTitle(L10n.Settings.healthKit)
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
