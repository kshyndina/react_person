import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject var appState: AppState

    private var excessivePermApps: [PhoneApp] {
        appState.installedApps
            .filter { $0.permissions.count > 4 }
            .sorted { $0.permissions.count > $1.permissions.count }
    }

    private var locationApps: [PhoneApp] {
        appState.installedApps.filter { $0.permissions.contains("Location") }
    }

    private var micApps: [PhoneApp] {
        appState.installedApps.filter { $0.permissions.contains("Microphone") }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    privacyScoreCard
                    excessivePermissions
                    locationTracking
                    microphoneAccess
                }
                .padding()
            }
            .navigationTitle("Privacy")
        }
    }

    // MARK: - Privacy Score

    private var privacyScoreCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: Double(appState.privacyScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(appState.privacyScore)")
                        .font(.system(size: 36, weight: .bold))
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Privacy Score")
                .font(.headline)
            Text(scoreDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var scoreColor: Color {
        if appState.privacyScore >= 70 { return .green }
        if appState.privacyScore >= 40 { return .orange }
        return .red
    }

    private var scoreDescription: String {
        if appState.privacyScore >= 70 { return "Good privacy posture. Keep monitoring app permissions." }
        if appState.privacyScore >= 40 { return "Moderate risk. Review apps with excessive permissions." }
        return "Poor privacy score. Many apps have excessive access."
    }

    // MARK: - Excessive Permissions

    private var excessivePermissions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Excessive Permissions", systemImage: "exclamationmark.shield.fill")
                .font(.headline)

            if excessivePermApps.isEmpty {
                Text("No apps with excessive permissions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(excessivePermApps) { app in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: app.icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading) {
                                Text(app.name)
                                    .fontWeight(.semibold)
                                Text("\(app.permissions.count) permissions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            RiskBadge(level: app.riskLevel)
                        }

                        FlowLayout(spacing: 6) {
                            ForEach(app.permissions, id: \.self) { perm in
                                Text(perm)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }

                        // Risk message
                        HStack(spacing: 4) {
                            Image(systemName: app.riskLevel == .high ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text(app.riskLevel == .high
                                ? "Consider removing or restricting this app"
                                : "Review and limit permissions in Settings")
                                .font(.caption)
                        }
                        .foregroundStyle(app.riskLevel == .high ? .red : .orange)
                    }
                    .padding()
                    .background(
                        (app.riskLevel == .high ? Color.red : Color.orange).opacity(0.05)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    // MARK: - Location Tracking

    private var locationTracking: some View {
        PermissionSection(
            title: "Location Tracking",
            icon: "location.fill",
            color: .blue,
            apps: locationApps
        )
    }

    // MARK: - Microphone Access

    private var microphoneAccess: some View {
        PermissionSection(
            title: "Microphone Access",
            icon: "mic.fill",
            color: .red,
            apps: micApps
        )
    }
}

// MARK: - Permission Section

struct PermissionSection: View {
    let title: String
    let icon: String
    let color: Color
    let apps: [PhoneApp]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            FlowLayout(spacing: 8) {
                ForEach(apps) { app in
                    HStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.caption2)
                        Text(app.name)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.1))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
