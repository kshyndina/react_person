import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var dailyReminder = true
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.pink)
                        VStack(alignment: .leading) {
                            Text("Never Forget Her")
                                .font(.headline)
                            Text("v1.0 — Built with love (and panic)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Notifications") {
                    Toggle("Daily Reminder", isOn: $dailyReminder)
                        .onChange(of: dailyReminder) { _, newValue in
                            if newValue {
                                NotificationScheduler.scheduleDailyCheck(partnerName: store.partner.name)
                            } else {
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-check"])
                            }
                        }

                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)

                    Button {
                        NotificationScheduler.requestPermission()
                        NotificationScheduler.scheduleAll(occasions: store.occasions, partnerName: store.partner.name)
                    } label: {
                        Label("Re-schedule All Reminders", systemImage: "bell.badge.fill")
                    }
                }

                Section("Reminder Schedule") {
                    VStack(alignment: .leading, spacing: 8) {
                        ReminderRow(days: "30 days before", desc: "Heads up — start thinking")
                        ReminderRow(days: "14 days before", desc: "Time to start shopping")
                        ReminderRow(days: "7 days before", desc: "Order now for delivery")
                        ReminderRow(days: "3 days before", desc: "Wrapping time")
                        ReminderRow(days: "1 day before", desc: "LAST CHANCE")
                        ReminderRow(days: "Day of", desc: "Did you remember?!")
                    }
                }

                Section("Data") {
                    HStack {
                        Text("Occasions")
                        Spacer()
                        Text("\(store.occasions.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Gift Ideas")
                        Spacer()
                        Text("\(store.allGiftIdeas.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Budget")
                        Spacer()
                        Text(String(format: "$%.0f", store.totalBudget))
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Danger Zone") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    VStack(spacing: 8) {
                        Text("Pro tips for not being in the doghouse:")
                            .font(.caption)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 6) {
                            TipRow(text: "Flowers are never wrong as a backup")
                            TipRow(text: "Card + handwritten note > expensive gift with no card")
                            TipRow(text: "\"I forgot\" is never an acceptable answer")
                            TipRow(text: "When in doubt: jewelry + dinner reservation")
                            TipRow(text: "Screenshot her Pinterest for easy wishlist mining")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Everything?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    store.partner = Partner.sample
                    store.occasions = defaultOccasions()
                    store.hasCompletedSetup = false
                    store.save()
                }
            } message: {
                Text("This will delete all occasions, gift ideas, and her profile. You'll go through setup again.")
            }
        }
    }
}

struct ReminderRow: View {
    let days: String
    let desc: String

    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .font(.caption2)
                .foregroundStyle(.pink)
            Text(days)
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
            Text(desc)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
