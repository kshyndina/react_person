import SwiftUI

struct PartnerProfileView: View {
    @EnvironmentObject var store: Store
    @State private var editing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatar
                    dates
                    sizes
                    interests
                    stats
                }
                .padding()
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(store.partner.name)
            .toolbar {
                Button("Edit") { editing = true }
            }
            .sheet(isPresented: $editing) {
                EditPartnerSheet()
            }
        }
    }

    // MARK: - Avatar

    private var avatar: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.pink, .purple.opacity(0.7)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 88, height: 88)

                Text(String(store.partner.name.prefix(1)).uppercased())
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(store.partner.name)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.top, 8)
    }

    // MARK: - Dates

    private var dates: some View {
        VStack(spacing: 0) {
            infoRow(icon: "birthday.cake.fill", label: "Birthday",
                    value: store.partner.birthday.formatted(.dateTime.month(.wide).day()), color: .pink)
            Divider().padding(.leading, 48)
            infoRow(icon: "heart.circle.fill", label: "Anniversary",
                    value: store.partner.anniversary.formatted(.dateTime.month(.wide).day()), color: .red)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func infoRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Sizes

    private var sizes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sizes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                sizeCard("Ring", store.partner.sizes.ring)
                sizeCard("Clothing", store.partner.sizes.clothing)
                sizeCard("Shoe", store.partner.sizes.shoe)
            }
        }
    }

    @ViewBuilder
    private func sizeCard(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value.isEmpty ? "—" : value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Interests

    private var interests: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interests")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if store.partner.interests.isEmpty {
                Text("None added yet")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                WrappingHStack(store.partner.interests, spacing: 8) { interest in
                    Text(interest.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.pink.opacity(0.08))
                        .foregroundStyle(.pink)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Stats

    private var stats: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                stat("\(store.occasions.count)", "Occasions", "calendar", .blue)
                stat("\(store.allGifts.count)", "Gift Ideas", "lightbulb", .yellow)
                stat(String(format: "$%.0f", store.totalBudget), "Budget", "dollarsign.circle", .green)
                stat(String(format: "$%.0f", store.totalSpent), "Spent", "cart", .purple)
            }
        }
    }

    @ViewBuilder
    private func stat(_ value: String, _ label: String, _ icon: String, _ color: Color) -> some View {
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
        .padding(.vertical, 14)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Edit Sheet

struct EditPartnerSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var birthday = Date()
    @State private var anniversary = Date()
    @State private var ring = ""
    @State private var clothing = "M"
    @State private var shoe = ""
    @State private var picked: Set<String> = []

    private let interestOptions = [
        "jewelry", "flowers", "skincare", "books", "travel",
        "cooking", "fashion", "tech", "fitness", "art", "music", "wine"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    DatePicker("Anniversary", selection: $anniversary, displayedComponents: .date)
                }

                Section("Sizes") {
                    TextField("Ring size", text: $ring)
                    Picker("Clothing", selection: $clothing) {
                        ForEach(["XS", "S", "M", "L", "XL"], id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Shoe size", text: $shoe)
                }

                Section("Interests") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(interestOptions, id: \.self) { i in
                            let on = picked.contains(i)
                            Button {
                                if on { picked.remove(i) } else { picked.insert(i) }
                            } label: {
                                Text(i.capitalized)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(on ? Color.pink : Color(.systemGray6))
                                    .foregroundStyle(on ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
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
                clothing = store.partner.sizes.clothing.isEmpty ? "M" : store.partner.sizes.clothing
                shoe = store.partner.sizes.shoe
                picked = Set(store.partner.interests)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.partner.name = name
                        store.partner.birthday = birthday
                        store.partner.anniversary = anniversary
                        store.partner.sizes = Sizes(ring: ring, clothing: clothing, shoe: shoe)
                        store.partner.interests = Array(picked)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Wrapping HStack

struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(_ data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        _WrappingLayout(spacing: spacing) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}

struct _WrappingLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (i, pos) in result.positions.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxW = proposal.width ?? .infinity
        var pts: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0

        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > maxW, x > 0 {
                x = 0; y += rowH + spacing; rowH = 0
            }
            pts.append(CGPoint(x: x, y: y))
            rowH = max(rowH, s.height)
            x += s.width + spacing
            maxX = max(maxX, x)
        }
        return (pts, CGSize(width: maxX, height: y + rowH))
    }
}
