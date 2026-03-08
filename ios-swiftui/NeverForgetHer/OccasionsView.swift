import SwiftUI

struct OccasionsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddOccasion = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Hero card for next occasion
                    if let next = store.nextOccasion {
                        NextUpCard(occasion: next, partnerName: store.partner.name)
                    }

                    // All occasions timeline
                    ForEach(store.upcomingOccasions) { occasion in
                        OccasionRow(occasion: occasion)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Upcoming")
            .toolbar {
                Button {
                    showAddOccasion = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.pink)
                }
            }
            .sheet(isPresented: $showAddOccasion) {
                AddOccasionSheet()
            }
        }
    }
}

// MARK: - Next Up Hero Card

struct NextUpCard: View {
    let occasion: Occasion
    let partnerName: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(urgencyMessage)
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(urgencyColor)

                    Text(occasion.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(occasion.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Countdown circle
                ZStack {
                    Circle()
                        .stroke(urgencyColor.opacity(0.2), lineWidth: 8)
                        .frame(width: 90, height: 90)

                    Circle()
                        .trim(from: 0, to: countdownFraction)
                        .stroke(urgencyColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(occasion.daysUntil)")
                            .font(.system(size: 32, weight: .bold))
                        Text("days")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Status bar
            HStack(spacing: 16) {
                Label(occasion.isPurchased ? "Gift Ready" : "No Gift Yet",
                      systemImage: occasion.isPurchased ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(occasion.isPurchased ? .green : .orange)

                Spacer()

                if let budget = occasion.budget {
                    Label("Budget: $\(Int(budget))", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Label("\(occasion.giftIdeas.count) ideas", systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [urgencyColor.opacity(0.08), urgencyColor.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: urgencyColor.opacity(0.15), radius: 10)
    }

    private var urgencyColor: Color {
        switch occasion.urgencyLevel {
        case .critical: return .red
        case .urgent: return .orange
        case .soon: return .yellow
        case .upcoming: return .blue
        case .relaxed: return .green
        }
    }

    private var countdownFraction: Double {
        let maxDays = 365.0
        return max(0, 1.0 - Double(occasion.daysUntil) / maxDays)
    }

    private var urgencyMessage: String {
        switch occasion.urgencyLevel {
        case .critical: return "PANIC MODE"
        case .urgent: return "This week — get moving!"
        case .soon: return "2 weeks — time to shop"
        case .upcoming: return "Coming up"
        case .relaxed: return "You have time"
        }
    }
}

// MARK: - Occasion Row

struct OccasionRow: View {
    let occasion: Occasion

    private var urgencyColor: Color {
        switch occasion.urgencyLevel {
        case .critical: return .red
        case .urgent: return .orange
        case .soon: return .yellow
        case .upcoming: return .blue
        case .relaxed: return .green
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Image(systemName: occasion.icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(urgencyColor.opacity(0.12))
                .foregroundStyle(urgencyColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(occasion.name)
                    .fontWeight(.semibold)
                Text(occasion.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Days countdown
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(occasion.daysUntil)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(urgencyColor)
                Text("days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Purchase status
            Image(systemName: occasion.isPurchased ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(occasion.isPurchased ? .green : .gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

// MARK: - Add Occasion Sheet

struct AddOccasionSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var date = Date()
    @State private var budget: Double = 100
    @State private var icon = "heart.fill"

    let icons = ["heart.fill", "star.fill", "gift.fill", "birthday.cake.fill",
                 "flame.fill", "moon.fill", "sun.max.fill", "sparkles"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Occasion") {
                    TextField("Name (e.g. Mother's Day)", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(icons, id: \.self) { ic in
                            Button {
                                icon = ic
                            } label: {
                                Image(systemName: ic)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(icon == ic ? Color.pink : Color(.systemGray5))
                                    .foregroundStyle(icon == ic ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                Section("Budget") {
                    HStack {
                        Slider(value: $budget, in: 25...1000, step: 25)
                        Text("$\(Int(budget))")
                            .fontWeight(.semibold)
                            .frame(width: 60)
                    }
                }
            }
            .navigationTitle("New Occasion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let occasion = Occasion(
                            name: name,
                            icon: icon,
                            date: date,
                            isRecurring: true,
                            isCustom: true,
                            reminderDaysBefore: [14, 7, 3, 1],
                            budget: budget,
                            giftIdeas: [],
                            isPurchased: false
                        )
                        store.addOccasion(occasion)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
