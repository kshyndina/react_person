import UserNotifications
import Foundation

struct NotificationScheduler {

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notifications enabled")
            }
        }
    }

    static func scheduleAll(occasions: [Occasion], partnerName: String) {
        let center = UNUserNotificationCenter.current()
        // Remove old ones
        center.removeAllPendingNotificationRequests()

        for occasion in occasions {
            for daysBefore in occasion.reminderDaysBefore {
                scheduleReminder(
                    occasion: occasion,
                    daysBefore: daysBefore,
                    partnerName: partnerName
                )
            }
        }
    }

    private static func scheduleReminder(occasion: Occasion, daysBefore: Int, partnerName: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1

        if daysBefore == 0 {
            content.title = "Today is \(occasion.name)!"
            content.body = "Hope you got \(partnerName) something great. If not... flowers + chocolate, GO NOW."
        } else if daysBefore == 1 {
            content.title = "\(occasion.name) is TOMORROW"
            content.body = "Last chance! Did you get \(partnerName)'s gift? Check the app for ideas."
        } else if daysBefore <= 3 {
            content.title = "\(occasion.name) in \(daysBefore) days"
            content.body = "Getting close! Make sure you've got \(partnerName)'s gift sorted."
        } else if daysBefore <= 7 {
            content.title = "\(occasion.name) next week"
            content.body = "One week out. Still time to order something great for \(partnerName)."
        } else if daysBefore <= 14 {
            content.title = "\(occasion.name) in 2 weeks"
            content.body = "Good time to start shopping for \(partnerName). Open the app for gift ideas."
        } else {
            content.title = "\(occasion.name) in \(daysBefore) days"
            content.body = "Start thinking about what to get \(partnerName). The app has suggestions!"
        }

        // Calculate trigger date
        let cal = Calendar.current
        guard let triggerDate = cal.date(byAdding: .day, value: -daysBefore, to: occasion.date) else { return }

        // Only schedule future notifications
        if triggerDate <= Date() { return }

        var dateComponents = cal.dateComponents([.year, .month, .day], from: triggerDate)
        dateComponents.hour = 9  // 9 AM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let id = "\(occasion.id.uuidString)-\(daysBefore)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            }
        }
    }

    static func scheduleDailyCheck(partnerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check"
        content.body = "Any upcoming dates for \(partnerName)? Open the app to see your timeline."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-check", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
