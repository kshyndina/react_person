import SwiftUI

struct GiftAdvisorView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedOccasion: Occasion?
    @State private var selectedBudget: BudgetTier = .moderate
    @State private var combos: [GiftCombo] = []
    @State private var hasGenerated = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(.pink)
                        Text("Gift Advisor")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Pick an occasion and budget,\nget curated gift combos for \(store.partner.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Occasion picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Occasion")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.upcomingOccasions) { occ in
                                    Button {
                                        selectedOccasion = occ
                                        hasGenerated = false
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: occ.icon)
                                                .font(.title3)
                                            Text(occ.name)
                                                .font(.caption2)
                                                .lineLimit(1)
                                            Text("\(occ.daysUntil)d")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(width: 90)
                                        .background(selectedOccasion?.id == occ.id ? Color.pink : Color(.systemGray5))
                                        .foregroundStyle(selectedOccasion?.id == occ.id ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Budget picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Budget")
                            .font(.headline)

                        ForEach(BudgetTier.allCases, id: \.self) { tier in
                            Button {
                                selectedBudget = tier
                                hasGenerated = false
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: tier.icon)
                                        .font(.body)
                                        .frame(width: 28)
                                    Text(tier.rawValue)
                                        .font(.subheadline)
                                    Spacer()
                                    if selectedBudget == tier {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.pink)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedBudget == tier ? Color.pink.opacity(0.1) : Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    // Generate button
                    Button {
                        if let occ = selectedOccasion {
                            combos = GiftEngine.suggestCombos(
                                for: occ,
                                interests: store.partner.interests,
                                budget: selectedBudget
                            )
                            hasGenerated = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Suggest Gift Combos")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOccasion == nil ? Color.gray : Color.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(selectedOccasion == nil)
                    .padding(.horizontal)

                    // Results
                    if hasGenerated {
                        VStack(spacing: 16) {
                            ForEach(Array(combos.enumerated()), id: \.element.id) { idx, combo in
                                ComboCard(combo: combo, index: idx + 1, occasionId: selectedOccasion!.id)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Gift Advisor")
        }
    }
}

// MARK: - Combo Card

struct ComboCard: View {
    @EnvironmentObject var store: AppStore
    let combo: GiftCombo
    let index: Int
    let occasionId: UUID

    @State private var isExpanded = false

    private let titles = ["Romantic Classic", "Experience & Pampering", "Thoughtful & Personal"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Option \(index)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.pink)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())

                            Text(titles[safe: index - 1] ?? "Combo")
                                .font(.headline)
                        }

                        Text(combo.formattedTotal)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.pink)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                // Reasoning
                Text(combo.reasoning)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.vertical, 4)

                // Items
                ForEach(combo.items) { gift in
                    HStack(spacing: 10) {
                        Image(systemName: gift.category.icon)
                            .font(.body)
                            .frame(width: 32, height: 32)
                            .background(Color.pink.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(gift.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(gift.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            if let pairs = gift.pairsWellWith {
                                HStack(spacing: 4) {
                                    Image(systemName: "link")
                                        .font(.caption2)
                                    Text("Pairs with: \(pairs)")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.pink)
                            }
                        }

                        Spacer()

                        Text(String(format: "$%.0f", gift.price))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Add all to wishlist
                Button {
                    for gift in combo.items {
                        let idea = GiftIdea(
                            name: gift.name,
                            category: gift.category,
                            priceEstimate: gift.price,
                            priceRange: String(format: "$%.0f-%.0f", gift.price * 0.8, gift.price * 1.2),
                            notes: gift.description,
                            isPurchased: false,
                            rating: 4
                        )
                        store.addGiftIdea(idea, to: occasionId)
                    }
                } label: {
                    Label("Add All to Wishlist", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.pink.opacity(0.1))
                        .foregroundStyle(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// Safe array access
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
