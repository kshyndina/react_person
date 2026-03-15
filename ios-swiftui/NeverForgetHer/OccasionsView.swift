import SwiftUI

struct OccasionsView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Next up — hero
                    if let next = store.upcoming.first {
                        heroCard(next)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                    }

                    // Timeline
                    ForEach(store.upcoming) { occ in
                        timelineRow(occ)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Upcoming")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddOccasionSheet()
            }
        }
    }

    // MARK: - Hero Card

    @ViewBuilder
    private func heroCard(_ occ: Occasion) -> some View {
        let color = urgencyColor(occ.urgency)

        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(occ.urgency.label.uppercased())
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(color)

                    Text(occ.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(occ.dateFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Ring countdown
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: min(1, max(0.02, 1 - Double(occ.daysUntil) / 365)))
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: -2) {
                        Text("\(occ.daysUntil)")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        Text("days")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
            }

            // Status chips
            HStack(spacing: 12) {
                chip(
                    icon: occ.purchased ? "checkmark.circle.fill" : "circle.dotted",
                    text: occ.purchased ? "Gift ready" : "No gift yet",
                    tint: occ.purchased ? .green : .orange
                )
                Spacer()
                chip(icon: "dollarsign.circle", text: "$\(Int(occ.budget))", tint: .secondary)
                chip(icon: "lightbulb", text: "\(occ.gifts.count) ideas", tint: .secondary)
            }
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    @ViewBuilder
    private func chip(icon: String, text: String, tint: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .foregroundStyle(tint)
    }

    // MARK: - Timeline Row

    @ViewBuilder
    private func timelineRow(_ occ: Occasion) -> some View {
        let color = urgencyColor(occ.urgency)

        HStack(spacing: 16) {
            // Icon
            Image(systemName: occ.emoji)
                .font(.body)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .foregroundStyle(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(occ.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(occ.dateFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(occ.daysUntil)d")
                .font(.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)

        Divider().padding(.leading, 76)
    }

    private func urgencyColor(_ u: Urgency) -> Color {
        switch u {
        case .now:       return .red
        case .thisWeek:  return .orange
        case .twoWeeks:  return .yellow
        case .thisMonth: return .blue
        case .plenty:    return .green
        }
    }
}

// MARK: - Add Occasion

struct AddOccasionSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var date = Date()
    @State private var budget: Double = 100
    @State private var emoji = "heart.fill"

    private let emojis = ["heart.fill", "star.fill", "gift.fill", "birthday.cake.fill",
                          "flame.fill", "moon.stars.fill", "sun.max.fill", "sparkles",
                          "figure.stand.dress", "cup.and.saucer.fill"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojis, id: \.self) { e in
                            Button { emoji = e } label: {
                                Image(systemName: e)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(emoji == e ? Color.pink : Color(.systemGray5))
                                    .foregroundStyle(emoji == e ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Budget")
                        Slider(value: $budget, in: 25...1000, step: 25)
                        Text("$\(Int(budget))").monospacedDigit().frame(width: 50)
                    }
                }
            }
            .navigationTitle("New Occasion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.occasions.append(Occasion(
                            name: name, emoji: emoji, date: date,
                            isCustom: true, reminderDays: [14,7,3,1],
                            budget: budget, gifts: []
                        ))
                        Notifier.scheduleAll(store.occasions, name: store.partner.name)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
