import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            Form {
                // Notifications
                Section("Notifications") {
                    Button {
                        Notifier.requestPermission()
                        Notifier.scheduleAll(store.occasions, name: store.partner.name)
                    } label: {
                        Label("Reschedule All Reminders", systemImage: "bell.badge")
                    }

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Notification Settings", systemImage: "gear")
                    }
                }

                // Reminder timeline
                Section("Reminder Timeline") {
                    reminder("30 days before", "Start thinking")
                    reminder("14 days before", "Time to shop")
                    reminder("7 days before", "Order for delivery")
                    reminder("3 days before", "Wrap it up")
                    reminder("1 day before", "LAST CHANCE")
                    reminder("Day of", "Did you remember?!")
                }

                // Data
                Section("Your Data") {
                    row("Occasions", "\(store.occasions.count)")
                    row("Gift Ideas", "\(store.allGifts.count)")
                    row("Total Budget", String(format: "$%.0f", store.totalBudget))
                    row("Spent So Far", String(format: "$%.0f", store.totalSpent))
                }

                // Tips
                Section("Survival Guide") {
                    tip("Flowers are never wrong as a backup plan")
                    tip("A card with a real note > expensive gift, no card")
                    tip("\"I forgot\" is not an acceptable answer")
                    tip("When in doubt: jewelry + dinner reservation")
                    tip("Screenshot her Pinterest for easy wishlist intel")
                    tip("Set reminders 30 days out — shipping takes time")
                }

                // Reset
                Section {
                    Button(role: .destructive) { showReset = true } label: {
                        Label("Reset Everything", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset all data?", isPresented: $showReset) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { store.reset() }
            } message: {
                Text("This deletes all occasions, gifts, and her profile.")
            }
        }
    }

    @ViewBuilder
    private func reminder(_ when: String, _ what: String) -> some View {
        HStack {
            Text(when)
                .font(.subheadline)
            Spacer()
            Text(what)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func tip(_ text: String) -> some View {
        Label(text, systemImage: "lightbulb")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
