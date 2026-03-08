import SwiftUI

struct PermissionsView: View {
    @StateObject private var permManager = PermissionManager()
    @State private var hasRequested = false

    private let allPermissions = [
        ("Camera", "camera.fill"),
        ("Microphone", "mic.fill"),
        ("Location", "location.fill"),
        ("Contacts", "person.crop.circle.fill"),
        ("Photos", "photo.fill"),
        ("Calendar", "calendar"),
        ("Reminders", "checklist"),
        ("Bluetooth", "antenna.radiowaves.left.and.right"),
        ("Motion", "figure.walk"),
        ("Health", "heart.fill"),
        ("Speech", "waveform"),
        ("Notifications", "bell.fill"),
        ("Face ID", "faceid"),
        ("Media Library", "music.note.list"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Grant All button
                    if !hasRequested {
                        Button(action: {
                            permManager.requestAll()
                            hasRequested = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.shield.fill")
                                Text("Grant All Permissions")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)

                        Text("Tap to request all device permissions at once.\niOS will show each prompt individually.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Permission list
                    VStack(spacing: 0) {
                        ForEach(allPermissions, id: \.0) { name, icon in
                            HStack(spacing: 12) {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .frame(width: 32)

                                Text(name)
                                    .fontWeight(.medium)

                                Spacer()

                                if let status = permManager.statuses[name] {
                                    Text(status)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(statusColor(status).opacity(0.15))
                                        .foregroundStyle(statusColor(status))
                                        .clipShape(Capsule())
                                } else {
                                    Text("Not Asked")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)

                            if name != allPermissions.last?.0 {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)

                    // Individual request buttons
                    if hasRequested {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Denied permissions can be enabled in:")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("Open iPhone Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Device Permissions")
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Granted", "Full Access", "Always":
            return .green
        case "When In Use", "Limited":
            return .orange
        case "Denied":
            return .red
        default:
            return .gray
        }
    }
}
