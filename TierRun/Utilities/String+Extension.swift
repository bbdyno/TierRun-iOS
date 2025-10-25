//
//  String+Extension.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation

extension String {
    /// Compatibility property for SwiftGen generated strings
    /// SwiftGen already returns localized strings, so this just returns self
    var localized: String {
        return self
    }
}
