import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var store: Store
    @State private var addingTo: Occasion?

    var body: some View {
        NavigationStack {
            List {
                // Summary
                Section {
                    HStack {
                        summaryPill(value: "\(store.allGifts.count)", label: "Ideas", color: .pink)
                        summaryPill(value: "\(store.allGifts.filter(\.bought).count)", label: "Bought", color: .green)
                        summaryPill(value: String(format: "$%.0f", store.totalSpent), label: "Spent", color: .blue)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                // Per-occasion
                ForEach(store.upcoming) { occ in
                    Section {
                        if occ.gifts.isEmpty {
                            emptyState(occ)
                        } else {
                            ForEach(occ.gifts) { gift in
                                giftRow(gift, in: occ)
                            }
                            .onDelete { indexSet in
                                for i in indexSet {
                                    store.removeGift(occ.gifts[i].id, from: occ.id)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: occ.emoji)
                            Text(occ.name)
                            Spacer()
                            Text("\(occ.daysUntil)d")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button { addingTo = occ } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.pink)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Gifts")
            .sheet(item: $addingTo) { occ in
                AddGiftSheet(occasionId: occ.id, occasionName: occ.name)
            }
        }
    }

    // MARK: - Summary pill

    @ViewBuilder
    private func summaryPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty state

    @ViewBuilder
    private func emptyState(_ occ: Occasion) -> some View {
        VStack(spacing: 8) {
            Text("No ideas yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Add Gift Idea") { addingTo = occ }
                .font(.subheadline)
                .tint(.pink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Gift row

    @ViewBuilder
    private func giftRow(_ gift: Gift, in occ: Occasion) -> some View {
        HStack(spacing: 12) {
            Image(systemName: gift.category.icon)
                .font(.subheadline)
                .frame(width: 32, height: 32)
                .background(Color.pink.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(gift.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(gift.bought, color: .secondary)

                HStack(spacing: 4) {
                    Text(gift.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.quaternary)

                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { s in
                            Image(systemName: s <= gift.love ? "heart.fill" : "heart")
                                .font(.system(size: 7))
                                .foregroundStyle(s <= gift.love ? .pink : Color(.systemGray4))
                        }
                    }
                }
            }

            Spacer()

            Text(gift.priceFormatted)
                .font(.subheadline)
                .fontWeight(.medium)
                .monospacedDigit()

            Button { store.toggleBought(gift.id, in: occ.id) } label: {
                Image(systemName: gift.bought ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(gift.bought ? .green : Color(.systemGray3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add Gift Sheet

struct AddGiftSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    let occasionId: UUID
    let occasionName: String

    @State private var name = ""
    @State private var category: GiftCategory = .jewelry
    @State private var price: Double = 50
    @State private var note = ""
    @State private var love = 3
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Gift name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(GiftCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Price") {
                    HStack {
                        Slider(value: $price, in: 0...2000, step: 5)
                        Text(price < 1 ? "Free" : "$\(Int(price))")
                            .monospacedDigit()
                            .frame(width: 50)
                    }
                }

                Section("She'd love it") {
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { s in
                            Button { love = s } label: {
                                Image(systemName: s <= love ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundStyle(s <= love ? .pink : Color(.systemGray4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section("Optional") {
                    TextField("Link", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    TextField("Notes (size, color...)", text: $note)
                }
            }
            .navigationTitle("Add to \(occasionName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addGift(Gift(
                            name: name, category: category, price: price,
                            url: url.isEmpty ? nil : url, note: note,
                            bought: false, love: love
                        ), to: occasionId)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
