//
//  Extensions.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let tierIron = Color.gray
    static let tierBronze = Color.brown
    static let tierSilver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let tierGold = Color.yellow
    static let tierPlatinum = Color.cyan
    static let tierEmerald = Color.green
    static let tierDiamond = Color.blue
    static let tierMaster = Color.purple
    static let tierGrandmaster = Color.red
    static let tierChallenger = Color.orange
}

// MARK: - Double Extensions
extension Double {
    func formatDistance() -> String {
        String(format: "%.2f km", self)
    }
    
    func formatPace() -> String {
        let minutes = Int(self)
        let seconds = Int((self - Double(minutes)) * 60)
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    func toKilometers() -> Double {
        self / 1000.0
    }
    
    func toMiles() -> Double {
        self * 0.621371
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func formatDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Date Extensions
extension Date {
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isThisWeek() -> Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func isThisMonth() -> Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? self
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
