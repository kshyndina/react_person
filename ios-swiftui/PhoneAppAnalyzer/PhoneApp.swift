import Foundation

// MARK: - Data Models

struct Subscription: Identifiable {
    let id = UUID()
    let plan: String
    let monthlyCost: Double
    let renewDate: String?
}

struct PhoneApp: Identifiable {
    let id: Int
    let name: String
    let category: String
    let icon: String          // SF Symbol name
    let sizeMB: Double
    let lastUsed: String
    let dailyUsageMin: Int
    let permissions: [String]
    let batteryUsage: Double   // percentage
    let dataUsageMB: Double
    let rating: Double
    let riskLevel: RiskLevel
    let subscription: Subscription

    var formattedUsage: String {
        let hours = dailyUsageMin / 60
        let mins = dailyUsageMin % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    var formattedData: String {
        if dataUsageMB >= 1000 {
            return String(format: "%.1f GB", dataUsageMB / 1000)
        }
        return String(format: "%.0f MB", dataUsageMB)
    }

    var formattedSize: String {
        if sizeMB >= 1000 {
            return String(format: "%.1f GB", sizeMB / 1000)
        }
        return String(format: "%.0f MB", sizeMB)
    }
}

enum RiskLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case size = "Size"
    case screenTime = "Screen Time"
    case battery = "Battery"
    case dataUsage = "Data Usage"
    case riskLevel = "Risk Level"
}

// MARK: - Permission Helpers

struct PermissionInfo {
    static func icon(for permission: String) -> String {
        switch permission {
        case "Camera": return "camera.fill"
        case "Microphone": return "mic.fill"
        case "Location": return "location.fill"
        case "Contacts": return "person.crop.circle.fill"
        case "Storage": return "externaldrive.fill"
        case "Phone": return "phone.fill"
        case "SMS": return "message.fill"
        case "Clipboard": return "doc.on.clipboard.fill"
        case "Network": return "wifi"
        case "Biometrics": return "faceid"
        case "Health Data": return "heart.fill"
        case "Sensors": return "sensor.fill"
        case "Notifications": return "bell.fill"
        default: return "questionmark.circle"
        }
    }

    static func isSensitive(_ permission: String) -> Bool {
        ["Camera", "Microphone", "Location", "Contacts", "Phone", "SMS"].contains(permission)
    }

    static func isMedium(_ permission: String) -> Bool {
        ["Clipboard", "Health Data", "Sensors", "Biometrics"].contains(permission)
    }
}

// MARK: - Sample Data

let sampleApps: [PhoneApp] = [
    PhoneApp(
        id: 1, name: "Instagram", category: "Social", icon: "camera.filters",
        sizeMB: 245, lastUsed: "2 hours ago", dailyUsageMin: 95,
        permissions: ["Camera", "Microphone", "Location", "Contacts", "Storage", "Notifications"],
        batteryUsage: 15, dataUsageMB: 850, rating: 4.5, riskLevel: .medium,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 2, name: "TikTok", category: "Entertainment", icon: "music.note",
        sizeMB: 380, lastUsed: "30 minutes ago", dailyUsageMin: 120,
        permissions: ["Camera", "Microphone", "Location", "Contacts", "Clipboard", "Storage", "Notifications"],
        batteryUsage: 20, dataUsageMB: 1200, rating: 4.3, riskLevel: .high,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 3, name: "WhatsApp", category: "Communication", icon: "message.fill",
        sizeMB: 180, lastUsed: "Just now", dailyUsageMin: 75,
        permissions: ["Camera", "Microphone", "Location", "Contacts", "Phone", "Storage", "Notifications"],
        batteryUsage: 10, dataUsageMB: 450, rating: 4.6, riskLevel: .medium,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 4, name: "Spotify", category: "Music", icon: "headphones",
        sizeMB: 320, lastUsed: "1 hour ago", dailyUsageMin: 180,
        permissions: ["Storage", "Notifications", "Network"],
        batteryUsage: 12, dataUsageMB: 600, rating: 4.7, riskLevel: .low,
        subscription: Subscription(plan: "Premium Family", monthlyCost: 16.99, renewDate: "Mar 15, 2026")
    ),
    PhoneApp(
        id: 5, name: "YouTube", category: "Entertainment", icon: "play.rectangle.fill",
        sizeMB: 410, lastUsed: "3 hours ago", dailyUsageMin: 90,
        permissions: ["Camera", "Microphone", "Storage", "Notifications"],
        batteryUsage: 18, dataUsageMB: 2100, rating: 4.4, riskLevel: .low,
        subscription: Subscription(plan: "Premium", monthlyCost: 13.99, renewDate: "Mar 22, 2026")
    ),
    PhoneApp(
        id: 6, name: "Netflix", category: "Entertainment", icon: "tv.fill",
        sizeMB: 290, lastUsed: "Yesterday", dailyUsageMin: 60,
        permissions: ["Storage", "Notifications"],
        batteryUsage: 14, dataUsageMB: 3500, rating: 4.2, riskLevel: .low,
        subscription: Subscription(plan: "Standard", monthlyCost: 15.49, renewDate: "Apr 1, 2026")
    ),
    PhoneApp(
        id: 7, name: "Chrome", category: "Productivity", icon: "globe",
        sizeMB: 210, lastUsed: "Just now", dailyUsageMin: 65,
        permissions: ["Camera", "Microphone", "Location", "Storage", "Clipboard", "Notifications"],
        batteryUsage: 11, dataUsageMB: 800, rating: 4.1, riskLevel: .medium,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 8, name: "Twitter/X", category: "Social", icon: "bubble.left.fill",
        sizeMB: 195, lastUsed: "4 hours ago", dailyUsageMin: 55,
        permissions: ["Camera", "Location", "Contacts", "Notifications"],
        batteryUsage: 8, dataUsageMB: 350, rating: 3.8, riskLevel: .medium,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 9, name: "Maps", category: "Navigation", icon: "map.fill",
        sizeMB: 150, lastUsed: "2 days ago", dailyUsageMin: 15,
        permissions: ["Location", "Notifications"],
        batteryUsage: 6, dataUsageMB: 200, rating: 4.5, riskLevel: .low,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 10, name: "Slack", category: "Productivity", icon: "number",
        sizeMB: 230, lastUsed: "1 hour ago", dailyUsageMin: 45,
        permissions: ["Camera", "Microphone", "Storage", "Notifications"],
        batteryUsage: 7, dataUsageMB: 250, rating: 4.3, riskLevel: .low,
        subscription: Subscription(plan: "Pro", monthlyCost: 8.75, renewDate: "Mar 30, 2026")
    ),
    PhoneApp(
        id: 11, name: "Banking", category: "Finance", icon: "banknote.fill",
        sizeMB: 95, lastUsed: "Today", dailyUsageMin: 5,
        permissions: ["Biometrics", "Notifications", "Camera"],
        batteryUsage: 2, dataUsageMB: 30, rating: 4.0, riskLevel: .low,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 12, name: "Weather", category: "Utility", icon: "cloud.sun.fill",
        sizeMB: 65, lastUsed: "Today", dailyUsageMin: 8,
        permissions: ["Location", "Notifications"],
        batteryUsage: 3, dataUsageMB: 45, rating: 4.2, riskLevel: .low,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 13, name: "Game Center", category: "Games", icon: "gamecontroller.fill",
        sizeMB: 890, lastUsed: "3 days ago", dailyUsageMin: 40,
        permissions: ["Microphone", "Storage", "Notifications"],
        batteryUsage: 16, dataUsageMB: 500, rating: 3.5, riskLevel: .low,
        subscription: Subscription(plan: "Game Pass", monthlyCost: 14.99, renewDate: "Apr 10, 2026")
    ),
    PhoneApp(
        id: 14, name: "Camera Pro", category: "Photography", icon: "camera.fill",
        sizeMB: 175, lastUsed: "Yesterday", dailyUsageMin: 12,
        permissions: ["Camera", "Microphone", "Location", "Storage"],
        batteryUsage: 5, dataUsageMB: 10, rating: 4.6, riskLevel: .low,
        subscription: Subscription(plan: "Pro", monthlyCost: 4.99, renewDate: "Mar 18, 2026")
    ),
    PhoneApp(
        id: 15, name: "Uber", category: "Travel", icon: "car.fill",
        sizeMB: 280, lastUsed: "1 week ago", dailyUsageMin: 10,
        permissions: ["Location", "Contacts", "Phone", "Notifications"],
        batteryUsage: 4, dataUsageMB: 120, rating: 4.1, riskLevel: .medium,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 16, name: "VPN Shield", category: "Security", icon: "lock.shield.fill",
        sizeMB: 85, lastUsed: "Always On", dailyUsageMin: 1440,
        permissions: ["Network"],
        batteryUsage: 9, dataUsageMB: 4500, rating: 4.4, riskLevel: .low,
        subscription: Subscription(plan: "Premium", monthlyCost: 9.99, renewDate: "May 1, 2026")
    ),
    PhoneApp(
        id: 17, name: "My Verizon", category: "Utility", icon: "antenna.radiowaves.left.and.right",
        sizeMB: 120, lastUsed: "Today", dailyUsageMin: 3,
        permissions: ["Phone", "Storage", "Notifications"],
        batteryUsage: 2, dataUsageMB: 50, rating: 3.2, riskLevel: .low,
        subscription: Subscription(plan: "Unlimited Plus", monthlyCost: 80.00, renewDate: "Mar 28, 2026")
    ),
    PhoneApp(
        id: 18, name: "Free Flashlight", category: "Utility", icon: "flashlight.on.fill",
        sizeMB: 45, lastUsed: "1 month ago", dailyUsageMin: 1,
        permissions: ["Camera", "Location", "Contacts", "Phone", "SMS", "Storage", "Clipboard"],
        batteryUsage: 1, dataUsageMB: 80, rating: 2.1, riskLevel: .high,
        subscription: Subscription(plan: "Free", monthlyCost: 0, renewDate: nil)
    ),
    PhoneApp(
        id: 19, name: "Fitness Tracker", category: "Health", icon: "figure.run",
        sizeMB: 160, lastUsed: "Today", dailyUsageMin: 25,
        permissions: ["Location", "Health Data", "Sensors", "Notifications"],
        batteryUsage: 6, dataUsageMB: 90, rating: 4.3, riskLevel: .low,
        subscription: Subscription(plan: "Premium", monthlyCost: 5.99, renewDate: "Apr 5, 2026")
    ),
]
