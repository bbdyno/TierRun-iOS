//
//  ActivityListView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ActivityListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ActivityViewModel?
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel, !vm.filteredRuns.isEmpty {
                    List {
                        ForEach(vm.filteredRuns) { run in
                            NavigationLink(destination: ActivityDetailView(run: run)) {
                                ActivityRowView(run: run)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    vm.deleteRun(run)
                                } label: {
                                    Label(L10n.Common.delete, systemImage: "trash")
                                }

                                Button {
                                    let newRole: RunRole = run.role == .marathoner ? .sprinter : .marathoner
                                    vm.reclassifyRun(run, to: newRole)
                                } label: {
                                    Label(L10n.Activity.reclassify, systemImage: "arrow.triangle.2.circlepath")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    ContentUnavailableView(
                        L10n.Activity.noActivities,
                        systemImage: "figure.run",
                        description: Text(L10n.Activity.NoActivities.description)
                    )
                }
            }
            .navigationTitle(L10n.Activity.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                if let vm = viewModel {
                    ActivityFiltersView(viewModel: vm)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ActivityViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

struct ActivityRowView: View {
    
    let run: Run
    
    var roleIcon: String {
        run.role == .marathoner ? "figure.run" : "bolt.fill"
    }
    
    var roleColor: Color {
        run.role == .marathoner ? .blue : .red
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Role indicator
            Image(systemName: roleIcon)
                .font(.title3)
                .foregroundStyle(roleColor)
                .frame(width: 32, height: 32)
                .background(roleColor.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(run.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                    
                    if let source = run.sourceApp {
                        Text("• \(source)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Label(String(format: "%.2f km", run.distance), systemImage: "figure.run")
                    Label(run.formattedDuration, systemImage: "clock")
                    Label(run.formattedPace, systemImage: "speedometer")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("+\(run.lpEarned)")
                .font(.headline)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    ActivityListView()
        .modelContainer(for: [User.self, Run.self], inMemory: true)
}
