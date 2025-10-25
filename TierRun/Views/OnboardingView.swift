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
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("RunClimb")
                    .font(.system(size: 56, weight: .bold))
                
                Text("Turn Your Runs into an Adventure")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("Swipe to continue")
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
                Text("How It Works")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                VStack(spacing: 24) {
                    FeatureCard(
                        icon: "figure.run",
                        color: .blue,
                        title: "Use Your Favorite App",
                        description: "Keep using Apple Watch, Nike Run Club, Strava, or any app. We sync from HealthKit."
                    )
                    
                    FeatureCard(
                        icon: "crown.fill",
                        color: .yellow,
                        title: "Tier System",
                        description: "Earn LP for every run. Climb through Iron to Challenger tier, just like League of Legends!"
                    )
                    
                    FeatureCard(
                        icon: "brain.head.profile",
                        color: .purple,
                        title: "AI-Powered Fair Play",
                        description: "Our AI adjusts for age, gender, and experience. Focus on personal improvement."
                    )
                    
                    FeatureCard(
                        icon: "rosette",
                        color: .green,
                        title: "Beautiful Certificates",
                        description: "Generate stunning tier certificates to share your achievements on social media."
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
                Text("HealthKit Integration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("We need access to your HealthKit data to:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HealthKitPermissionRow(
                    icon: "figure.run",
                    text: "Read your running workouts"
                )
                
                HealthKitPermissionRow(
                    icon: "heart.fill",
                    text: "Analyze your heart rate data"
                )
                
                HealthKitPermissionRow(
                    icon: "moon.fill",
                    text: "Check your sleep patterns"
                )
                
                HealthKitPermissionRow(
                    icon: "figure.walk",
                    text: "Track your activity levels"
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Text("🔒 Your data never leaves your device")
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
