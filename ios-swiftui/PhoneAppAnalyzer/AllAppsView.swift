import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var sortOption: SortOption = .name
    @State private var expandedAppId: Int?

    private var filteredApps: [PhoneApp] {
        var apps = appState.installedApps

        // Search
        if !searchText.isEmpty {
            apps = apps.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Category filter
        if selectedCategory != "All" {
            apps = apps.filter { $0.category == selectedCategory }
        }

        // Sort
        switch sortOption {
        case .name:
            apps.sort { $0.name < $1.name }
        case .size:
            apps.sort { $0.sizeMB > $1.sizeMB }
        case .screenTime:
            apps.sort { $0.dailyUsageMin > $1.dailyUsageMin }
        case .battery:
            apps.sort { $0.batteryUsage > $1.batteryUsage }
        case .dataUsage:
            apps.sort { $0.dataUsageMB > $1.dataUsageMB }
        case .riskLevel:
            apps.sort { $0.riskLevel.sortOrder < $1.riskLevel.sortOrder }
        }

        return apps
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                VStack(spacing: 10) {
                    // Category picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(name: "All", isSelected: selectedCategory == "All") {
                                selectedCategory = "All"
                            }
                            ForEach(appState.categories, id: \.self) { cat in
                                CategoryChip(name: cat, isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Sort picker
                    HStack {
                        Text("\(filteredApps.count) apps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

                // App list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredApps) { app in
                            AppCardView(app: app, isExpanded: expandedAppId == app.id) {
                                withAnimation(.spring(response: 0.3)) {
                                    expandedAppId = expandedAppId == app.id ? nil : app.id
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("All Apps")
            .searchable(text: $searchText, prompt: "Search apps...")
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - App Card

struct AppCardView: View {
    let app: PhoneApp
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: app.icon)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.headline)
                        HStack(spacing: 6) {
                            Text(app.category)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                            RiskBadge(level: app.riskLevel)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(app.formattedSize)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding()

            // Expanded details
            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    // Usage stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MiniStat(icon: "clock", label: "Daily Use", value: app.formattedUsage)
                        MiniStat(icon: "battery.50", label: "Battery", value: String(format: "%.0f%%", app.batteryUsage))
                        MiniStat(icon: "arrow.up.arrow.down", label: "Data", value: app.formattedData)
                        MiniStat(icon: "star.fill", label: "Rating", value: String(format: "%.1f", app.rating))
                        MiniStat(icon: "clock.arrow.circlepath", label: "Last Used", value: app.lastUsed)
                        MiniStat(icon: "internaldrive", label: "Size", value: app.formattedSize)
                    }

                    // Permissions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Permissions (\(app.permissions.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        FlowLayout(spacing: 6) {
                            ForEach(app.permissions, id: \.self) { perm in
                                HStack(spacing: 4) {
                                    Image(systemName: PermissionInfo.icon(for: perm))
                                        .font(.caption2)
                                    Text(perm)
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(permissionColor(perm).opacity(0.15))
                                .foregroundStyle(permissionColor(perm))
                                .clipShape(Capsule())
                            }
                        }

                        if app.permissions.count > 4 {
                            Label("This app requests excessive permissions", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func permissionColor(_ perm: String) -> Color {
        if PermissionInfo.isSensitive(perm) { return .red }
        if PermissionInfo.isMedium(perm) { return .orange }
        return .blue
    }
}

struct MiniStat: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Flow Layout (for permission tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
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
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}
