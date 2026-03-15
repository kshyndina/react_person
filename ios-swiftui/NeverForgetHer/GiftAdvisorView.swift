import SwiftUI

struct GiftAdvisorView: View {
    @EnvironmentObject var store: Store
    @State private var selectedOccasion: Occasion?
    @State private var tier: BudgetTier = .mid
    @State private var results: [GiftCombo] = []
    @State private var showResults = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    occasionPicker
                    budgetPicker
                    generateButton

                    if showResults {
                        resultsSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Gift Ideas")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 36))
                .foregroundStyle(.pink)
                .padding(.top, 8)
            Text("Pick occasion & budget")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Occasion Picker

    private var occasionPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Occasion")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.upcoming) { occ in
                        let on = selectedOccasion?.id == occ.id
                        Button {
                            selectedOccasion = occ
                            showResults = false
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: occ.emoji)
                                    .font(.title3)
                                Text(occ.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .frame(width: 80)
                            .padding(.vertical, 12)
                            .background(on ? Color.pink : Color(.systemBackground))
                            .foregroundStyle(on ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(on ? 0 : 0.03), radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Budget Picker

    private var budgetPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Budget")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 2) {
                ForEach(BudgetTier.allCases) { t in
                    let on = tier == t
                    Button {
                        tier = t
                        showResults = false
                    } label: {
                        HStack {
                            Text(t.rawValue)
                                .font(.subheadline)
                            Spacer()
                            if on {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.pink)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(on ? Color.pink.opacity(0.06) : Color(.systemBackground))
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Generate

    private var generateButton: some View {
        Button {
            guard let occ = selectedOccasion else { return }
            withAnimation(.spring(response: 0.4)) {
                results = GiftEngine.suggest(occasion: occ, interests: store.partner.interests, tier: tier)
                showResults = true
            }
        } label: {
            Text("Suggest Gift Combos")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedOccasion == nil ? Color(.systemGray4) : Color.pink)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(selectedOccasion == nil)
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(results.enumerated()), id: \.element.id) { i, combo in
                comboCard(combo, number: i + 1)
            }
        }
    }

    @ViewBuilder
    private func comboCard(_ combo: GiftCombo, number: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("\(number)")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .frame(width: 22, height: 22)
                    .background(Color.pink)
                    .foregroundStyle(.white)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(combo.title)
                        .font(.headline)
                    Text(combo.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(format: "$%.0f", combo.total))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.pink)
            }

            // Items
            ForEach(combo.items) { item in
                HStack(spacing: 10) {
                    Image(systemName: item.category.icon)
                        .font(.caption)
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 7))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(item.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if let pair = item.pairsWith {
                            Text("Pairs with \(pair)")
                                .font(.caption2)
                                .foregroundStyle(.pink)
                        }
                    }

                    Spacer()

                    Text(String(format: "$%.0f", item.price))
                        .font(.subheadline)
                        .monospacedDigit()
                }
            }

            // Add all
            Button {
                guard let occ = selectedOccasion else { return }
                for item in combo.items {
                    store.addGift(Gift(
                        name: item.name, category: item.category, price: item.price,
                        note: item.detail, bought: false, love: 4
                    ), to: occ.id)
                }
            } label: {
                Label("Add All to Wishlist", systemImage: "plus.circle")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.pink.opacity(0.08))
                    .foregroundStyle(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
    }
}
