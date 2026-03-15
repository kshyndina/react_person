import UserNotifications

enum Notifier {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func scheduleAll(_ occasions: [Occasion], name: String) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for occ in occasions {
            for days in occ.reminderDays {
                schedule(occ: occ, daysBefore: days, name: name)
            }
            // Day-of
            schedule(occ: occ, daysBefore: 0, name: name)
        }
    }

    private static func schedule(occ: Occasion, daysBefore: Int, name: String) {
        let cal = Calendar.current
        guard let fire = cal.date(byAdding: .day, value: -daysBefore, to: occ.date),
              fire > Date() else { return }

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1

        switch daysBefore {
        case 0:
            content.title = "\(occ.name) is TODAY"
            content.body = "Did you get \(name) something? If not — flowers + chocolate. Go. Now."
        case 1:
            content.title = "\(occ.name) is TOMORROW"
            content.body = "Last chance to get \(name)'s gift sorted."
        case 2...3:
            content.title = "\(occ.name) in \(daysBefore) days"
            content.body = "Cutting it close. Make sure \(name)'s gift is ready."
        case 4...7:
            content.title = "\(occ.name) this week"
            content.body = "Have you ordered \(name)'s gift yet? Open the app for ideas."
        case 8...14:
            content.title = "\(occ.name) in \(daysBefore) days"
            content.body = "Good time to start shopping for \(name)."
        default:
            content.title = "\(occ.name) in \(daysBefore) days"
            content.body = "Start thinking about what to get \(name)."
        }

        var dc = cal.dateComponents([.year, .month, .day], from: fire)
        dc.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
        let req = UNNotificationRequest(
            identifier: "\(occ.id)-\(daysBefore)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(req)
    }
}
