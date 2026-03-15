import Foundation

// MARK: - Partner

struct Partner: Codable, Identifiable {
    var id = UUID()
    var name: String
    var birthday: Date
    var anniversary: Date
    var interests: [String]
    var sizes: Sizes

    static let empty = Partner(
        name: "",
        birthday: Date(),
        anniversary: Date(),
        interests: [],
        sizes: .empty
    )
}

struct Sizes: Codable {
    var ring: String
    var clothing: String
    var shoe: String

    static let empty = Sizes(ring: "", clothing: "", shoe: "")
}

// MARK: - Occasion

struct Occasion: Codable, Identifiable {
    var id = UUID()
    var name: String
    var emoji: String
    var date: Date
    var isCustom: Bool
    var reminderDays: [Int]
    var budget: Double
    var gifts: [Gift]

    var daysUntil: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var target = cal.startOfDay(for: date)
        if target < today, let next = cal.date(byAdding: .year, value: 1, to: target) {
            target = next
        }
        return max(0, cal.dateComponents([.day], from: today, to: target).day ?? 0)
    }

    var urgency: Urgency {
        switch daysUntil {
        case 0...1:  return .now
        case 2...7:  return .thisWeek
        case 8...14: return .twoWeeks
        case 15...30: return .thisMonth
        default:     return .plenty
        }
    }

    var dateFormatted: String {
        date.formatted(.dateTime.month(.wide).day())
    }

    var purchased: Bool {
        !gifts.isEmpty && gifts.allSatisfy(\.bought)
    }

    var totalSpent: Double {
        gifts.filter(\.bought).reduce(0) { $0 + $1.price }
    }
}

enum Urgency {
    case now, thisWeek, twoWeeks, thisMonth, plenty

    var label: String {
        switch self {
        case .now:       return "Today"
        case .thisWeek:  return "This Week"
        case .twoWeeks:  return "Soon"
        case .thisMonth: return "This Month"
        case .plenty:    return "All Good"
        }
    }

    var tint: String {
        switch self {
        case .now:       return "red"
        case .thisWeek:  return "orange"
        case .twoWeeks:  return "yellow"
        case .thisMonth: return "blue"
        case .plenty:    return "green"
        }
    }
}

// MARK: - Gift

struct Gift: Codable, Identifiable {
    var id = UUID()
    var name: String
    var category: GiftCategory
    var price: Double
    var url: String?
    var note: String
    var bought: Bool
    var love: Int  // 1–5

    var priceFormatted: String {
        price < 1 ? "Free" : String(format: "$%.0f", price)
    }
}

enum GiftCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case jewelry     = "Jewelry"
    case flowers     = "Flowers"
    case skincare    = "Skincare"
    case clothing    = "Clothing"
    case experience  = "Experience"
    case tech        = "Tech"
    case books       = "Books"
    case food        = "Food & Drink"
    case home        = "Home"
    case travel      = "Travel"
    case handmade    = "Handmade"
    case subscription = "Subscription"

    var icon: String {
        switch self {
        case .jewelry:     return "sparkles"
        case .flowers:     return "leaf.fill"
        case .skincare:    return "drop.fill"
        case .clothing:    return "tshirt.fill"
        case .experience:  return "ticket.fill"
        case .tech:        return "desktopcomputer"
        case .books:       return "book.fill"
        case .food:        return "fork.knife"
        case .home:        return "house.fill"
        case .travel:      return "airplane"
        case .handmade:    return "heart.fill"
        case .subscription: return "arrow.clockwise"
        }
    }
}

// MARK: - Budget Tier

enum BudgetTier: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case under50   = "Under $50"
    case mid       = "$50–150"
    case generous  = "$150–300"
    case splurge   = "$300–500"
    case allOut    = "$500+"

    var max: Double {
        switch self {
        case .under50:  return 50
        case .mid:      return 150
        case .generous: return 300
        case .splurge:  return 500
        case .allOut:   return 5000
        }
    }

    var multiplier: Double {
        switch self {
        case .under50:  return 0.3
        case .mid:      return 0.7
        case .generous: return 1.0
        case .splurge:  return 1.6
        case .allOut:   return 2.8
        }
    }
}

// MARK: - Gift Suggestion

struct GiftCombo: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let items: [SuggestedItem]
    var total: Double { items.reduce(0) { $0 + $1.price } }
}

struct SuggestedItem: Identifiable {
    let id = UUID()
    let name: String
    let category: GiftCategory
    let price: Double
    let detail: String
    let pairsWith: String?
}

// MARK: - Gift Engine

enum GiftEngine {
    static func suggest(occasion: Occasion, interests: [String], tier: BudgetTier) -> [GiftCombo] {
        let m = tier.multiplier
        let pool = buildPool(m: m, interests: interests)

        return [
            buildCombo(
                title: "Classic Romance",
                subtitle: "Can't go wrong with the classics",
                pool: pool,
                prefer: [.flowers, .jewelry, .food],
                cap: tier.max, m: m
            ),
            buildCombo(
                title: "Experience Together",
                subtitle: "Memories over things",
                pool: pool,
                prefer: [.experience, .food, .skincare],
                cap: tier.max, m: m
            ),
            buildCombo(
                title: "Thoughtful & Personal",
                subtitle: "Shows you actually pay attention",
                pool: pool,
                prefer: [.books, .handmade, .subscription, .home],
                cap: tier.max, m: m
            ),
        ]
    }

    private static func buildCombo(title: String, subtitle: String, pool: [SuggestedItem], prefer: [GiftCategory], cap: Double, m: Double) -> GiftCombo {
        var picked: [SuggestedItem] = []
        var left = cap

        for cat in prefer {
            if let item = pool.first(where: { $0.category == cat && $0.price <= left && !picked.contains(where: { $0.name == item.name }) }) {
                picked.append(item)
                left -= item.price
            }
        }
        if picked.count < 2 {
            for item in pool where !picked.contains(where: { $0.category == item.category }) && item.price <= left {
                picked.append(item)
                left -= item.price
                if picked.count >= 3 { break }
            }
        }
        return GiftCombo(title: title, subtitle: subtitle, items: picked)
    }

    private static func buildPool(m: Double, interests: [String]) -> [SuggestedItem] {
        var pool: [SuggestedItem] = [
            .init(name: "Long-Stem Roses", category: .flowers, price: r(50, m), detail: "Two dozen red, hand-tied", pairsWith: "Dinner"),
            .init(name: "Seasonal Bouquet", category: .flowers, price: r(40, m), detail: "Peonies & ranunculus in a ceramic vase", pairsWith: "Chocolate"),
            .init(name: "Gold Pendant Necklace", category: .jewelry, price: r(130, m), detail: "14k gold, small diamond", pairsWith: "Flowers"),
            .init(name: "Pearl Stud Earrings", category: .jewelry, price: r(90, m), detail: "Freshwater pearl, classic", pairsWith: "Necklace"),
            .init(name: "Couples Spa Day", category: .experience, price: r(160, m), detail: "Full day — massage, facial, sauna", pairsWith: "Dinner out"),
            .init(name: "Concert Tickets", category: .experience, price: r(140, m), detail: "Two tickets to her favorite artist", pairsWith: "Dinner"),
            .init(name: "Fine Dining", category: .food, price: r(110, m), detail: "Tasting menu at a top restaurant", pairsWith: "Flowers"),
            .init(name: "Artisan Chocolates", category: .food, price: r(45, m), detail: "Hand-crafted Belgian, 24 piece", pairsWith: "Wine"),
            .init(name: "Luxury Skincare Set", category: .skincare, price: r(90, m), detail: "Drunk Elephant or La Mer gift set", pairsWith: "Candles"),
            .init(name: "Silk Pajama Set", category: .clothing, price: r(100, m), detail: "Premium silk, monogrammable", pairsWith: "Skincare"),
            .init(name: "Cashmere Scarf", category: .clothing, price: r(120, m), detail: "100% cashmere, her favorite color", pairsWith: "Gloves"),
            .init(name: "Kindle Paperwhite", category: .tech, price: r(85, m), detail: "Latest model, waterproof", pairsWith: "Book subscription"),
            .init(name: "Dyson Airwrap", category: .tech, price: r(220, m), detail: "Multi-styler, all hair types", pairsWith: "Skincare set"),
            .init(name: "Her Favorite Author", category: .books, price: r(28, m), detail: "Special edition or signed copy", pairsWith: "Candle + blanket"),
            .init(name: "Photo Book", category: .handmade, price: r(65, m), detail: "Hardcover book of your best moments", pairsWith: "Handwritten letter"),
            .init(name: "Love Letter", category: .handmade, price: r(5, m), detail: "On nice stationery, wax-sealed", pairsWith: "Anything"),
            .init(name: "Jo Malone Candle Set", category: .home, price: r(60, m), detail: "Trio of luxury scented candles", pairsWith: "Bath set"),
            .init(name: "Book of the Month", category: .subscription, price: r(55, m), detail: "6-month subscription", pairsWith: "Kindle"),
            .init(name: "Flower Subscription", category: .subscription, price: r(50, m), detail: "Monthly bouquet, 3 months", pairsWith: "Vase"),
            .init(name: "Weekend Getaway", category: .travel, price: r(280, m), detail: "2 nights at a boutique hotel", pairsWith: "Spa"),
        ]

        if interests.contains("skincare") {
            pool.append(.init(name: "LED Face Mask", category: .skincare, price: r(160, m), detail: "Professional LED therapy at home", pairsWith: "Serum set"))
        }
        if interests.contains("travel") {
            pool.append(.init(name: "Leather Luggage Tags", category: .travel, price: r(50, m), detail: "Personalized, hand-stitched", pairsWith: "Weekend trip"))
        }
        if interests.contains("wine") {
            pool.append(.init(name: "Wine Tasting", category: .experience, price: r(95, m), detail: "Private tasting for two at a local vineyard", pairsWith: "Cheese board"))
        }

        return pool.sorted { $0.price < $1.price }
    }

    private static func r(_ base: Double, _ m: Double) -> Double {
        (base * m).rounded(.toNearestOrEven)
    }
}

// MARK: - Default Occasions

func makeDefaultOccasions() -> [Occasion] {
    let cal = Calendar.current
    let y = cal.component(.year, from: Date())
    func d(_ month: Int, _ day: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: month, day: day))!
    }
    return [
        Occasion(name: "Valentine's Day", emoji: "heart.fill", date: d(2,14), isCustom: false, reminderDays: [30,14,7,3,1], budget: 200, gifts: []),
        Occasion(name: "Women's Day", emoji: "figure.stand.dress", date: d(3,8), isCustom: false, reminderDays: [14,7,3,1], budget: 100, gifts: []),
        Occasion(name: "Her Birthday", emoji: "birthday.cake.fill", date: d(7,15), isCustom: false, reminderDays: [30,14,7,3,1], budget: 300, gifts: []),
        Occasion(name: "Anniversary", emoji: "heart.circle.fill", date: d(9,3), isCustom: false, reminderDays: [30,14,7,3,1], budget: 250, gifts: []),
        Occasion(name: "Christmas", emoji: "gift.fill", date: d(12,25), isCustom: false, reminderDays: [30,14,7,3,1], budget: 300, gifts: []),
    ]
}
