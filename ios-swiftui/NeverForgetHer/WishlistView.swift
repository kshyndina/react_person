import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddGift = false
    @State private var selectedOccasion: Occasion?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick stats
                    HStack(spacing: 12) {
                        WishlistStat(
                            value: "\(store.allGiftIdeas.count)",
                            label: "Ideas",
                            icon: "lightbulb.fill",
                            color: .yellow
                        )
                        WishlistStat(
                            value: "\(store.allGiftIdeas.filter { $0.isPurchased }.count)",
                            label: "Bought",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        WishlistStat(
                            value: String(format: "$%.0f", store.totalSpent),
                            label: "Spent",
                            icon: "dollarsign.circle.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Per-occasion wishlists
                    ForEach(store.upcomingOccasions) { occasion in
                        OccasionWishlistSection(occasion: occasion) {
                            selectedOccasion = occasion
                            showAddGift = true
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Wishlist")
            .sheet(isPresented: $showAddGift) {
                if let occasion = selectedOccasion {
                    AddGiftSheet(occasionId: occasion.id, occasionName: occasion.name)
                }
            }
        }
    }
}

// MARK: - Stat Card

struct WishlistStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

// MARK: - Per-Occasion Section

struct OccasionWishlistSection: View {
    @EnvironmentObject var store: AppStore
    let occasion: Occasion
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: occasion.icon)
                    .foregroundStyle(.pink)
                Text(occasion.name)
                    .font(.headline)
                Spacer()
                Text("\(occasion.daysUntil) days")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.pink)
                }
            }
            .padding(.horizontal)

            if occasion.giftIdeas.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "gift")
                            .font(.title)
                            .foregroundStyle(.gray)
                        Text("No gift ideas yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Add Gift Idea", action: onAdd)
                            .font(.caption)
                            .buttonStyle(.bordered)
                            .tint(.pink)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(occasion.giftIdeas) { gift in
                    GiftIdeaRow(gift: gift, occasionId: occasion.id)
                }
                .padding(.horizontal)

                // Occasion total
                let total = occasion.giftIdeas.reduce(0) { $0 + $1.priceEstimate }
                HStack {
                    Spacer()
                    Text("Total: \(String(format: "$%.0f", total))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    if let budget = occasion.budget {
                        Text("/ $\(Int(budget)) budget")
                            .font(.caption2)
                            .foregroundStyle(total > budget ? .red : .green)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 3)
        .padding(.horizontal)
    }
}

// MARK: - Gift Idea Row

struct GiftIdeaRow: View {
    @EnvironmentObject var store: AppStore
    let gift: GiftIdea
    let occasionId: UUID

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: gift.category.icon)
                .font(.body)
                .frame(width: 36, height: 36)
                .background(Color.pink.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(gift.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(gift.isPurchased)

                HStack(spacing: 6) {
                    Text(gift.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())

                    // Star rating
                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= gift.rating ? "star.fill" : "star")
                                .font(.system(size: 8))
                                .foregroundStyle(star <= gift.rating ? .yellow : .gray)
                        }
                    }
                }
            }

            Spacer()

            // Price
            Text(gift.formattedPrice)
                .font(.subheadline)
                .fontWeight(.semibold)

            // Purchase toggle
            Button {
                store.togglePurchased(gift.id, in: occasionId)
            } label: {
                Image(systemName: gift.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(gift.isPurchased ? .green : .gray)
                    .font(.title3)
            }
        }
        .padding(10)
        .background(gift.isPurchased ? Color.green.opacity(0.05) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Add Gift Sheet

struct AddGiftSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let occasionId: UUID
    let occasionName: String

    @State private var name = ""
    @State private var category: GiftCategory = .jewelry
    @State private var price: Double = 50
    @State private var notes = ""
    @State private var rating = 3
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Gift") {
                    TextField("What is it?", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(GiftCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Price Estimate") {
                    HStack {
                        Slider(value: $price, in: 5...2000, step: 5)
                        Text("$\(Int(price))")
                            .fontWeight(.semibold)
                            .frame(width: 60)
                    }
                }

                Section("How much would she love it?") {
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= rating ? .yellow : .gray)
                            }
                        }
                    }
                }

                Section("Link (optional)") {
                    TextField("https://...", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }

                Section("Notes") {
                    TextField("Size, color, variant...", text: $notes)
                }
            }
            .navigationTitle("Add to \(occasionName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let gift = GiftIdea(
                            name: name,
                            category: category,
                            priceEstimate: price,
                            priceRange: "$\(Int(price * 0.8))-\(Int(price * 1.2))",
                            url: url.isEmpty ? nil : url,
                            notes: notes,
                            isPurchased: false,
                            rating: rating
                        )
                        store.addGiftIdea(gift, to: occasionId)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
