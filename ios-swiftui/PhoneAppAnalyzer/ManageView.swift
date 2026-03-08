import SwiftUI

struct ManageView: View {
    @EnvironmentObject var appState: AppState
    @State private var appToDelete: PhoneApp?
    @State private var showDeleteConfirm = false

    private var freedMB: Double {
        appState.deletedApps.reduce(0) { $0 + $1.sizeMB }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Storage savings
                    if !appState.deletedApps.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(String(format: "%.0f MB freed", freedMB))
                                    .font(.headline)
                                Text("\(appState.deletedApps.count) app(s) removed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Installed apps
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Installed Apps (\(appState.installedApps.count))")
                            .font(.headline)

                        ForEach(appState.installedApps.sorted(by: { $0.name < $1.name })) { app in
                            HStack(spacing: 12) {
                                Image(systemName: app.icon)
                                    .font(.title3)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.name)
                                        .fontWeight(.medium)
                                    HStack(spacing: 8) {
                                        Text(app.formattedSize)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(app.category)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }

                                Spacer()

                                Button(role: .destructive) {
                                    appToDelete = app
                                    showDeleteConfirm = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.body)
                                        .foregroundStyle(.red)
                                        .padding(8)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(10)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // Recently removed
                    if !appState.deletedApps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recently Removed")
                                .font(.headline)

                            ForEach(appState.deletedApps) { app in
                                HStack(spacing: 12) {
                                    Image(systemName: app.icon)
                                        .font(.title3)
                                        .frame(width: 40, height: 40)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .opacity(0.5)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(app.name)
                                            .fontWeight(.medium)
                                            .strikethrough()
                                            .foregroundStyle(.secondary)
                                        Text(app.formattedSize)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        withAnimation { appState.restoreApp(app) }
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Manage Apps")
            .alert("Delete App?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let app = appToDelete {
                        withAnimation { appState.deleteApp(app) }
                    }
                }
            } message: {
                if let app = appToDelete {
                    Text("Remove \(app.name) (\(app.formattedSize))? You can restore it later.")
                }
            }
        }
    }
}
