import SwiftUI

struct PartnerProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)

                            Text(String(store.partner.name.prefix(1)).uppercased())
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Text(store.partner.name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top)

                    // Key dates
                    VStack(spacing: 0) {
                        ProfileInfoRow(icon: "birthday.cake.fill", label: "Birthday",
                                      value: formatted(store.partner.birthday), color: .pink)
                        Divider().padding(.leading, 50)
                        ProfileInfoRow(icon: "heart.circle.fill", label: "Anniversary",
                                      value: formatted(store.partner.anniversary), color: .red)
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.03), radius: 3)
                    .padding(.horizontal)

                    // Sizes
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Her Sizes", systemImage: "ruler.fill")
                            .font(.headline)

                        HStack(spacing: 16) {
                            SizeChip(label: "Ring", value: store.partner.sizes.ring)
                            SizeChip(label: "Clothing", value: store.partner.sizes.clothing)
                            SizeChip(label: "Shoe", value: store.partner.sizes.shoe)
                        }
                    }
                    .padding(.horizontal)

                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Interests", systemImage: "sparkles")
                            .font(.headline)

                        if store.partner.interests.isEmpty {
                            Text("No interests added yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            FlowLayout(spacing: 8) {
                                ForEach(store.partner.interests, id: \.self) { interest in
                                    Text(interest.capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(Color.pink.opacity(0.12))
                                        .foregroundStyle(.pink)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Gift Stats", systemImage: "chart.bar.fill")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ProfileStatCard(
                                value: "\(store.occasions.count)",
                                label: "Occasions",
                                icon: "calendar",
                                color: .blue
                            )
                            ProfileStatCard(
                                value: "\(store.allGiftIdeas.count)",
                                label: "Gift Ideas",
                                icon: "lightbulb.fill",
                                color: .yellow
                            )
                            ProfileStatCard(
                                value: String(format: "$%.0f", store.totalBudget),
                                label: "Total Budget",
                                icon: "dollarsign.circle.fill",
                                color: .green
                            )
                            ProfileStatCard(
                                value: String(format: "$%.0f", store.totalSpent),
                                label: "Spent",
                                icon: "cart.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Her Profile")
            .toolbar {
                Button {
                    isEditing = true
                } label: {
                    Text("Edit")
                }
            }
            .sheet(isPresented: $isEditing) {
                EditPartnerSheet()
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: date)
    }
}

// MARK: - Components

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct SizeChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value.isEmpty ? "?" : value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Edit Sheet

struct EditPartnerSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var birthday: Date = Date()
    @State private var anniversary: Date = Date()
    @State private var ring: String = ""
    @State private var clothing: String = ""
    @State private var shoe: String = ""
    @State private var selectedInterests: Set<String> = []

    let interestOptions = ["jewelry", "flowers", "skincare", "books", "travel",
                           "cooking", "fashion", "tech", "fitness", "art", "music", "wine"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    DatePicker("Anniversary", selection: $anniversary, displayedComponents: .date)
                }

                Section("Sizes") {
                    TextField("Ring Size", text: $ring)
                    Picker("Clothing", selection: $clothing) {
                        ForEach(["XS", "S", "M", "L", "XL"], id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    TextField("Shoe Size", text: $shoe)
                }

                Section("Interests") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(interestOptions, id: \.self) { interest in
                            Button {
                                if selectedInterests.contains(interest) {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            } label: {
                                Text(interest.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedInterests.contains(interest) ? Color.pink : Color(.systemGray5))
                                    .foregroundStyle(selectedInterests.contains(interest) ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = store.partner.name
                birthday = store.partner.birthday
                anniversary = store.partner.anniversary
                ring = store.partner.sizes.ring
                clothing = store.partner.sizes.clothing
                shoe = store.partner.sizes.shoe
                selectedInterests = Set(store.partner.interests)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.partner.name = name
                        store.partner.birthday = birthday
                        store.partner.anniversary = anniversary
                        store.partner.sizes = PartnerSizes(ring: ring, clothing: clothing, shoe: shoe)
                        store.partner.interests = Array(selectedInterests)
                        store.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangeSubviews(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }
        return (positions, CGSize(width: maxX, height: y + lineHeight))
    }
}
