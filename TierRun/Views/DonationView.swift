//
//  DonationView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct DonationView: View {
    
    @State private var selectedAmount = 2
    @State private var showingCopiedAlert = false
    
    let amounts = [1, 2, 5, 10]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.red)
                    
                    Text("Support RunClimb")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("RunClimb is completely free with no ads. Your support helps keep it that way!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Amount Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Amount")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(amounts, id: \.self) { amount in
                            Button {
                                selectedAmount = amount
                            } label: {
                                Text("$\(amount)")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedAmount == amount ? Color.blue : Color(.secondarySystemBackground))
                                    .foregroundStyle(selectedAmount == amount ? .white : .primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Donation Methods
                VStack(alignment: .leading, spacing: 16) {
                    Text("Donation Methods")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Bitcoin
                    DonationMethodCard(
                        icon: "bitcoinsign.circle.fill",
                        title: "Bitcoin",
                        address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
                        color: .orange,
                        showingCopiedAlert: $showingCopiedAlert
                    )
                    
                    // Ethereum
                    DonationMethodCard(
                        icon: "e.circle.fill",
                        title: "Ethereum",
                        address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
                        color: .purple,
                        showingCopiedAlert: $showingCopiedAlert
                    )
                }
                
                // Thank You Message
                VStack(spacing: 8) {
                    Text("Thank You! 🙏")
                        .font(.headline)
                    
                    Text("Every contribution helps maintain and improve RunClimb for the running community.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Donate")
        .alert("Copied!", isPresented: $showingCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Address copied to clipboard")
        }
    }
}

struct DonationMethodCard: View {
    
    let icon: String
    let title: String
    let address: String
    let color: Color
    @Binding var showingCopiedAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = address
                    showingCopiedAlert = true
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        DonationView()
    }
}
