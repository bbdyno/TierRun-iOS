//
//  ContentView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(L10n.Tab.home.localized, systemImage: "house.fill")
                }
                .tag(0)

            TierView()
                .tabItem {
                    Label(L10n.Tab.tier.localized, systemImage: "crown.fill")
                }
                .tag(1)

            ActivityListView()
                .tabItem {
                    Label(L10n.Tab.activity.localized, systemImage: "figure.run")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(L10n.Tab.profile.localized, systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Tier.self, Run.self], inMemory: true)
}
