//
//  ActivityFiltersView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

struct ActivityFiltersView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ActivityViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Role") {
                    Picker("Filter", selection: $viewModel.selectedFilter) {
                        ForEach(RunFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Period") {
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        viewModel.selectedFilter = .all
                        viewModel.selectedPeriod = .all
                        viewModel.sortOrder = .dateDescending
                        viewModel.applyFilters()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
