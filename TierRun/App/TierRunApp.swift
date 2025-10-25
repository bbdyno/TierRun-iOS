//
//  TierRunApp.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import SwiftUI
import SwiftData

@main
struct TierRunApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Tier.self,
            Run.self,
            Achievement.self,
            Title.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
