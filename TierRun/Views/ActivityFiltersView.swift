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
                Section(L10n.Filter.role) {
                    Picker(L10n.Filter.title, selection: $viewModel.selectedFilter) {
                        ForEach(RunFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.Filter.period) {
                    Picker(L10n.Filter.period, selection: $viewModel.selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }

                Section(L10n.Filter.sortBy) {
                    Picker(L10n.Filter.sort, selection: $viewModel.sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                }
            }
            .navigationTitle(L10n.Filter.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.Common.reset) {
                        viewModel.selectedFilter = .all
                        viewModel.selectedPeriod = .all
                        viewModel.sortOrder = .dateDescending
                        viewModel.applyFilters()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
