//
//  NotificationManager.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleNewRunNotification(lpEarned: Int, currentLP: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Run Completed! 🎉"
        content.body = "You earned +\(lpEarned) LP! Total: \(currentLP) LP"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTierPromotionNotification(tier: TierLevel, grade: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Tier Promotion! 👑"
        content.body = "Congratulations! You've reached \(tier.rawValue.capitalized) \(grade)!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleGradeUpNotification(tier: TierLevel, grade: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Grade Up! ⬆️"
        content.body = "You've advanced to \(tier.rawValue.capitalized) \(grade)!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleWeeklySummaryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Summary 📊"
        content.body = "Check out your running stats from this week!"
        content.sound = .default
        
        // Schedule for Monday 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 9
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly-summary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleMotivationalNotification() {
        let motivationalMessages = [
            "Time to lace up! Your next run awaits 🏃‍♂️",
            "Every run counts towards your next tier! 💪",
            "The road to Challenger starts with a single step",
            "Your competition is training. Are you? 🔥",
            "Consistency is key. Let's keep that streak going!"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "TierRun"
        content.body = motivationalMessages.randomElement() ?? "Time to run!"
        content.sound = .default
        
        // Schedule for 6 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "motivational",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
