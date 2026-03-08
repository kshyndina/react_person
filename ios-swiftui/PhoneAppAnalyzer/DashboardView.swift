import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsGrid
                    securityAlerts
                    topScreenTime
                    topBatteryDrainers
                    topDataConsumers
                    topLargestApps
                    permissionBreakdown
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "Total Apps", value: "\(appState.installedApps.count)", icon: "square.grid.2x2", color: .blue)
            StatCard(title: "Storage", value: appState.totalStorageGB, icon: "internaldrive", color: .purple)
            StatCard(title: "Screen Time", value: appState.formattedScreenTime, icon: "clock.fill", color: .orange)
            StatCard(title: "Battery Drain", value: String(format: "%.0f%%", appState.totalBattery), icon: "battery.25", color: .red)
            StatCard(title: "Data Used", value: appState.totalDataFormatted, icon: "arrow.up.arrow.down", color: .green)
            StatCard(title: "High Risk", value: "\(appState.highRiskCount)", icon: "exclamationmark.triangle.fill", color: .red)
        }
    }

    // MARK: - Security Alerts

    private var securityAlerts: some View {
        let highRisk = appState.installedApps.filter { $0.riskLevel == .high }
        let mediumRisk = appState.installedApps.filter { $0.riskLevel == .medium }

        return Group {
            if !highRisk.isEmpty || !mediumRisk.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Security Alerts", systemImage: "shield.exclamationmark.fill")
                        .font(.headline)

                    ForEach(highRisk) { app in
                        HStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundStyle(.red)
                            VStack(alignment: .leading) {
                                Text(app.name).fontWeight(.semibold)
                                Text("\(app.permissions.count) permissions - excessive access")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            RiskBadge(level: app.riskLevel)
                        }
                        .padding(10)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    ForEach(mediumRisk) { app in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading) {
                                Text(app.name).fontWeight(.semibold)
                                Text("Review permissions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            RiskBadge(level: app.riskLevel)
                        }
                        .padding(10)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5)
            }
        }
    }

    // MARK: - Bar Chart Sections

    private var topScreenTime: some View {
        let top5 = appState.installedApps
            .sorted { $0.dailyUsageMin > $1.dailyUsageMin }
            .prefix(5)
        let maxVal = Double(top5.first?.dailyUsageMin ?? 1)

        return BarChartSection(
            title: "Top Screen Time",
            icon: "clock.fill",
            items: top5.map { ($0.name, Double($0.dailyUsageMin), $0.formattedUsage) },
            maxValue: maxVal,
            color: .orange
        )
    }

    private var topBatteryDrainers: some View {
        let top5 = appState.installedApps
            .sorted { $0.batteryUsage > $1.batteryUsage }
            .prefix(5)
        let maxVal = top5.first?.batteryUsage ?? 1

        return BarChartSection(
            title: "Top Battery Drainers",
            icon: "battery.25",
            items: top5.map { ($0.name, $0.batteryUsage, String(format: "%.0f%%", $0.batteryUsage)) },
            maxValue: maxVal,
            color: .red
        )
    }

    private var topDataConsumers: some View {
        let top5 = appState.installedApps
            .sorted { $0.dataUsageMB > $1.dataUsageMB }
            .prefix(5)
        let maxVal = top5.first?.dataUsageMB ?? 1

        return BarChartSection(
            title: "Top Data Consumers",
            icon: "arrow.up.arrow.down",
            items: top5.map { ($0.name, $0.dataUsageMB, $0.formattedData) },
            maxValue: maxVal,
            color: .green
        )
    }

    private var topLargestApps: some View {
        let top5 = appState.installedApps
            .sorted { $0.sizeMB > $1.sizeMB }
            .prefix(5)
        let maxVal = top5.first?.sizeMB ?? 1

        return BarChartSection(
            title: "Largest Apps",
            icon: "internaldrive",
            items: top5.map { ($0.name, $0.sizeMB, $0.formattedSize) },
            maxValue: maxVal,
            color: .purple
        )
    }

    // MARK: - Permission Breakdown

    private var permissionBreakdown: some View {
        let allPerms = appState.installedApps.flatMap { $0.permissions }
        let permCounts = Dictionary(grouping: allPerms) { $0 }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        let maxCount = Double(permCounts.first?.value ?? 1)

        return BarChartSection(
            title: "Most Requested Permissions",
            icon: "hand.raised.fill",
            items: permCounts.prefix(5).map { ($0.key, Double($0.value), "\($0.value) apps") },
            maxValue: maxCount,
            color: .indigo
        )
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        let catCounts = Dictionary(grouping: appState.installedApps) { $0.category }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }

        return VStack(alignment: .leading, spacing: 12) {
            Label("Apps by Category", systemImage: "folder.fill")
                .font(.headline)

            ForEach(catCounts, id: \.key) { cat, count in
                HStack {
                    Text(cat)
                        .font(.subheadline)
                    Spacer()
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Reusable Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RiskBadge: View {
    let level: RiskLevel

    var color: Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    var body: some View {
        Text(level.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct BarChartSection: View {
    let title: String
    let icon: String
    let items: [(String, Double, String)]
    let maxValue: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.0)
                            .font(.subheadline)
                        Spacer()
                        Text(item.2)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.gradient)
                            .frame(width: geo.size.width * CGFloat(item.1 / maxValue))
                    }
                    .frame(height: 12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
