import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var appState: AppState

    private var paidApps: [PhoneApp] {
        appState.installedApps
            .filter { $0.subscription.monthlyCost > 0 }
            .sorted { $0.subscription.monthlyCost > $1.subscription.monthlyCost }
    }

    private var freeApps: [PhoneApp] {
        appState.installedApps.filter { $0.subscription.monthlyCost == 0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCards
                    activeSubscriptions
                    freeAppsList
                }
                .padding()
            }
            .navigationTitle("Subscriptions")
        }
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Monthly Cost",
                value: String(format: "$%.2f", appState.monthlyCost),
                icon: "dollarsign.circle.fill",
                color: .green
            )
            StatCard(
                title: "Yearly Cost",
                value: String(format: "$%.2f", appState.monthlyCost * 12),
                icon: "calendar",
                color: .blue
            )
            StatCard(
                title: "Paid Apps",
                value: "\(paidApps.count)",
                icon: "creditcard.fill",
                color: .purple
            )
            StatCard(
                title: "Free Apps",
                value: "\(freeApps.count)",
                icon: "gift.fill",
                color: .orange
            )
        }
    }

    // MARK: - Active Subscriptions

    private var activeSubscriptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Active Subscriptions", systemImage: "creditcard.fill")
                .font(.headline)

            ForEach(paidApps) { app in
                HStack(spacing: 12) {
                    Image(systemName: app.icon)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .fontWeight(.semibold)
                        Text(app.subscription.plan)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.2f/mo", app.subscription.monthlyCost))
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                        if let renewDate = app.subscription.renewDate {
                            Text("Renews \(renewDate)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Free Apps

    private var freeAppsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Free Apps", systemImage: "gift.fill")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(freeApps) { app in
                    HStack(spacing: 4) {
                        Image(systemName: app.icon)
                            .font(.caption)
                        Text(app.name)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
