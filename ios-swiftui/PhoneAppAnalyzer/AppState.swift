import SwiftUI

// MARK: - Shared App State

class AppState: ObservableObject {
    @Published var installedApps: [PhoneApp] = sampleApps
    @Published var deletedApps: [PhoneApp] = []
    @Published var hasScanned: Bool = false
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0

    // Computed properties
    var totalStorageMB: Double {
        installedApps.reduce(0) { $0 + $1.sizeMB }
    }

    var totalStorageGB: String {
        String(format: "%.1f GB", totalStorageMB / 1000)
    }

    var totalScreenTimeMin: Int {
        installedApps.reduce(0) { $0 + $1.dailyUsageMin }
    }

    var formattedScreenTime: String {
        let hours = totalScreenTimeMin / 60
        let mins = totalScreenTimeMin % 60
        return "\(hours)h \(mins)m"
    }

    var totalBattery: Double {
        installedApps.reduce(0) { $0 + $1.batteryUsage }
    }

    var totalDataMB: Double {
        installedApps.reduce(0) { $0 + $1.dataUsageMB }
    }

    var totalDataFormatted: String {
        String(format: "%.1f GB", totalDataMB / 1000)
    }

    var highRiskCount: Int {
        installedApps.filter { $0.riskLevel == .high }.count
    }

    var privacyScore: Int {
        let totalPerms = installedApps.reduce(0) { $0 + $1.permissions.count }
        let count = max(installedApps.count, 1)
        return max(0, min(100, 100 - (totalPerms * 2) / count))
    }

    var monthlyCost: Double {
        installedApps.reduce(0) { $0 + $1.subscription.monthlyCost }
    }

    var categories: [String] {
        Array(Set(installedApps.map { $0.category })).sorted()
    }

    func deleteApp(_ app: PhoneApp) {
        if let index = installedApps.firstIndex(where: { $0.id == app.id }) {
            let removed = installedApps.remove(at: index)
            deletedApps.append(removed)
        }
    }

    func restoreApp(_ app: PhoneApp) {
        if let index = deletedApps.firstIndex(where: { $0.id == app.id }) {
            let restored = deletedApps.remove(at: index)
            installedApps.append(restored)
        }
    }

    func startScan() {
        isScanning = true
        scanProgress = 0
        // Simulate scanning
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            DispatchQueue.main.async {
                self.scanProgress += 0.02
                if self.scanProgress >= 1.0 {
                    timer.invalidate()
                    self.isScanning = false
                    self.hasScanned = true
                }
            }
        }
    }
}
