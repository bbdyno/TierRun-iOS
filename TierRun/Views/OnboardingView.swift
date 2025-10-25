//
//  OnboardingView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomePageView()
                .tag(0)
            
            ConceptPageView()
                .tag(1)
            
            HealthKitExplanationView()
                .tag(2)
            
            BasicInfoView(onContinue: {
                currentPage = 4
            })
            .tag(3)
            
            PlacementTestView()
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct WelcomePageView: View {
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 16) {
                Text(L10n.Onboarding.welcome)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text(L10n.Onboarding.appName)
                    .font(.system(size: 56, weight: .bold))

                Text(L10n.Onboarding.tagline)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text(L10n.Onboarding.swipeToContinue)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

struct ConceptPageView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text(L10n.Onboarding.howItWorks)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                VStack(spacing: 24) {
                    FeatureCard(
                        icon: "figure.run",
                        color: .blue,
                        title: L10n.Onboarding.useYourFavoriteApp,
                        description: L10n.Onboarding.useYourFavoriteAppDesc
                    )

                    FeatureCard(
                        icon: "crown.fill",
                        color: .yellow,
                        title: L10n.Onboarding.tierSystem,
                        description: L10n.Onboarding.tierSystemDesc
                    )

                    FeatureCard(
                        icon: "brain.head.profile",
                        color: .purple,
                        title: L10n.Onboarding.aiPowered,
                        description: L10n.Onboarding.aiPoweredDesc
                    )

                    FeatureCard(
                        icon: "rosette",
                        color: .green,
                        title: L10n.Onboarding.beautifulCertificates,
                        description: L10n.Onboarding.beautifulCertificatesDesc
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct HealthKitExplanationView: View {
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 100))
                .foregroundStyle(.red)
            
            VStack(spacing: 16) {
                Text(L10n.Onboarding.healthKitIntegration)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(L10n.Onboarding.healthKitIntegrationDesc)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HealthKitPermissionRow(
                    icon: "figure.run",
                    text: L10n.Onboarding.readWorkouts
                )

                HealthKitPermissionRow(
                    icon: "heart.fill",
                    text: L10n.Onboarding.analyzeHeartRate
                )

                HealthKitPermissionRow(
                    icon: "moon.fill",
                    text: L10n.Onboarding.checkSleep
                )

                HealthKitPermissionRow(
                    icon: "figure.walk",
                    text: L10n.Onboarding.trackActivity
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Text(L10n.Onboarding.privacyMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct HealthKitPermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
