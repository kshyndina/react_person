import Foundation

// MARK: - Partner

struct Partner: Codable, Identifiable {
    var id = UUID()
    var name: String
    var birthday: Date
    var anniversary: Date
    var photoData: Data?
    var interests: [String]  // e.g. ["jewelry", "books", "skincare", "travel"]
    var sizes: PartnerSizes

    static let sample = Partner(
        name: "Kate",
        birthday: Calendar.current.date(from: DateComponents(year: 1994, month: 7, day: 15))!,
        anniversary: Calendar.current.date(from: DateComponents(year: 2021, month: 9, day: 3))!,
        interests: ["jewelry", "skincare", "books", "travel", "flowers"],
        sizes: PartnerSizes(ring: "6", clothing: "S", shoe: "7")
    )
}

struct PartnerSizes: Codable {
    var ring: String
    var clothing: String  // XS, S, M, L, XL
    var shoe: String
}

// MARK: - Occasion

struct Occasion: Codable, Identifiable {
    var id = UUID()
    var name: String
    var icon: String        // SF Symbol
    var date: Date          // next occurrence
    var isRecurring: Bool
    var isCustom: Bool
    var reminderDaysBefore: [Int]  // e.g. [30, 14, 7, 3, 1]
    var budget: Double?
    var giftIdeas: [GiftIdea]
    var isPurchased: Bool

    var daysUntil: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var targetDate = cal.startOfDay(for: date)

        // If the date has passed this year, move to next year
        if targetDate < today {
            if let nextYear = cal.date(byAdding: .year, value: 1, to: targetDate) {
                targetDate = nextYear
            }
        }
        return cal.dateComponents([.day], from: today, to: targetDate).day ?? 0
    }

    var urgencyLevel: UrgencyLevel {
        if daysUntil <= 3 { return .critical }
        if daysUntil <= 7 { return .urgent }
        if daysUntil <= 14 { return .soon }
        if daysUntil <= 30 { return .upcoming }
        return .relaxed
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

enum UrgencyLevel: String {
    case critical = "NOW!"
    case urgent = "This Week"
    case soon = "2 Weeks"
    case upcoming = "This Month"
    case relaxed = "You're Good"

    var color: String {
        switch self {
        case .critical: return "red"
        case .urgent: return "orange"
        case .soon: return "yellow"
        case .upcoming: return "blue"
        case .relaxed: return "green"
        }
    }
}

// MARK: - Gift Idea

struct GiftIdea: Codable, Identifiable {
    var id = UUID()
    var name: String
    var category: GiftCategory
    var priceEstimate: Double
    var priceRange: String      // "$50-80"
    var url: String?
    var notes: String
    var isPurchased: Bool
    var rating: Int             // 1-5 how much she'd like it

    var formattedPrice: String {
        String(format: "$%.0f", priceEstimate)
    }
}

enum GiftCategory: String, Codable, CaseIterable {
    case jewelry = "Jewelry"
    case flowers = "Flowers"
    case skincare = "Skincare"
    case clothing = "Clothing"
    case experience = "Experience"
    case tech = "Tech"
    case books = "Books"
    case food = "Food & Drink"
    case home = "Home"
    case travel = "Travel"
    case custom = "Custom/DIY"
    case subscription = "Subscription"

    var icon: String {
        switch self {
        case .jewelry: return "sparkles"
        case .flowers: return "camera.macro"
        case .skincare: return "drop.fill"
        case .clothing: return "tshirt.fill"
        case .experience: return "ticket.fill"
        case .tech: return "desktopcomputer"
        case .books: return "book.fill"
        case .food: return "fork.knife"
        case .home: return "house.fill"
        case .travel: return "airplane"
        case .custom: return "heart.fill"
        case .subscription: return "arrow.clockwise"
        }
    }
}

// MARK: - Budget Tier

enum BudgetTier: String, CaseIterable {
    case budget = "Under $50"
    case moderate = "$50 - $150"
    case generous = "$150 - $300"
    case splurge = "$300 - $500"
    case allOut = "$500+"

    var range: ClosedRange<Double> {
        switch self {
        case .budget: return 0...50
        case .moderate: return 50...150
        case .generous: return 150...300
        case .splurge: return 300...500
        case .allOut: return 500...10000
        }
    }

    var icon: String {
        switch self {
        case .budget: return "dollarsign"
        case .moderate: return "dollarsign.circle"
        case .generous: return "dollarsign.circle.fill"
        case .splurge: return "star.circle.fill"
        case .allOut: return "crown.fill"
        }
    }
}

// MARK: - Gift Suggestion (AI-generated combos)

struct GiftCombo: Identifiable {
    let id = UUID()
    let occasionName: String
    let tier: BudgetTier
    let items: [SuggestedGift]
    let totalPrice: Double
    let reasoning: String

    var formattedTotal: String {
        String(format: "$%.0f", totalPrice)
    }
}

struct SuggestedGift: Identifiable {
    let id = UUID()
    let name: String
    let category: GiftCategory
    let price: Double
    let description: String
    let pairsWellWith: String?
}

// MARK: - Sample Data

func defaultOccasions() -> [Occasion] {
    let cal = Calendar.current
    let year = cal.component(.year, from: Date())

    return [
        Occasion(
            name: "Valentine's Day",
            icon: "heart.fill",
            date: cal.date(from: DateComponents(year: year, month: 2, day: 14))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [30, 14, 7, 3, 1],
            budget: 200,
            giftIdeas: [],
            isPurchased: false
        ),
        Occasion(
            name: "International Women's Day",
            icon: "figure.stand.dress",
            date: cal.date(from: DateComponents(year: year, month: 3, day: 8))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [14, 7, 3, 1],
            budget: 100,
            giftIdeas: [],
            isPurchased: false
        ),
        Occasion(
            name: "Her Birthday",
            icon: "birthday.cake.fill",
            date: cal.date(from: DateComponents(year: year, month: 7, day: 15))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [30, 14, 7, 3, 1],
            budget: 300,
            giftIdeas: [],
            isPurchased: false
        ),
        Occasion(
            name: "Anniversary",
            icon: "heart.circle.fill",
            date: cal.date(from: DateComponents(year: year, month: 9, day: 3))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [30, 14, 7, 3, 1],
            budget: 250,
            giftIdeas: [],
            isPurchased: false
        ),
        Occasion(
            name: "Christmas",
            icon: "gift.fill",
            date: cal.date(from: DateComponents(year: year, month: 12, day: 25))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [30, 14, 7, 3, 1],
            budget: 300,
            giftIdeas: [],
            isPurchased: false
        ),
        Occasion(
            name: "New Year's Eve",
            icon: "sparkles",
            date: cal.date(from: DateComponents(year: year, month: 12, day: 31))!,
            isRecurring: true,
            isCustom: false,
            reminderDaysBefore: [14, 7, 3],
            budget: 150,
            giftIdeas: [],
            isPurchased: false
        ),
    ]
}

// MARK: - Sample Gift Suggestions Engine

struct GiftEngine {

    static func suggestCombos(for occasion: Occasion, interests: [String], budget: BudgetTier) -> [GiftCombo] {
        let pool = giftPool(interests: interests, budget: budget)

        // Generate 3 combo options
        var combos: [GiftCombo] = []

        // Combo 1: Classic romantic
        let romantic = pickGifts(from: pool, categories: [.flowers, .jewelry, .food], budget: budget)
        combos.append(GiftCombo(
            occasionName: occasion.name,
            tier: budget,
            items: romantic,
            totalPrice: romantic.reduce(0) { $0 + $1.price },
            reasoning: "Classic romantic combo — flowers set the mood, jewelry makes it memorable, dinner seals the deal."
        ))

        // Combo 2: Experience-focused
        let experiential = pickGifts(from: pool, categories: [.experience, .food, .skincare], budget: budget)
        combos.append(GiftCombo(
            occasionName: occasion.name,
            tier: budget,
            items: experiential,
            totalPrice: experiential.reduce(0) { $0 + $1.price },
            reasoning: "Experience over things — create memories together. Pair with pampering for the full effect."
        ))

        // Combo 3: Thoughtful personal
        let thoughtful = pickGifts(from: pool, categories: [.books, .custom, .subscription], budget: budget)
        combos.append(GiftCombo(
            occasionName: occasion.name,
            tier: budget,
            items: thoughtful,
            totalPrice: thoughtful.reduce(0) { $0 + $1.price },
            reasoning: "Shows you actually pay attention to what she likes. Personal > expensive every time."
        ))

        return combos
    }

    private static func pickGifts(from pool: [SuggestedGift], categories: [GiftCategory], budget: BudgetTier) -> [SuggestedGift] {
        var result: [SuggestedGift] = []
        var remaining = budget.range.upperBound

        for cat in categories {
            if let gift = pool.first(where: { $0.category == cat && $0.price <= remaining }) {
                result.append(gift)
                remaining -= gift.price
            }
        }
        // Fill with anything that fits
        if result.count < 2 {
            for gift in pool where !result.contains(where: { $0.category == gift.category }) && gift.price <= remaining {
                result.append(gift)
                remaining -= gift.price
                if result.count >= 3 { break }
            }
        }
        return result
    }

    private static func giftPool(interests: [String], budget: BudgetTier) -> [SuggestedGift] {
        let multiplier: Double = {
            switch budget {
            case .budget: return 0.3
            case .moderate: return 0.6
            case .generous: return 1.0
            case .splurge: return 1.5
            case .allOut: return 2.5
            }
        }()

        var gifts: [SuggestedGift] = [
            SuggestedGift(name: "Red Roses Bouquet", category: .flowers, price: 45 * multiplier,
                         description: "Classic long-stem red roses, 2 dozen", pairsWellWith: "Jewelry"),
            SuggestedGift(name: "Peony & Ranunculus Arrangement", category: .flowers, price: 65 * multiplier,
                         description: "Seasonal premium arrangement in a vase", pairsWellWith: "Chocolate"),
            SuggestedGift(name: "Gold Pendant Necklace", category: .jewelry, price: 120 * multiplier,
                         description: "14k gold with small diamond pendant", pairsWellWith: "Flowers"),
            SuggestedGift(name: "Tennis Bracelet", category: .jewelry, price: 180 * multiplier,
                         description: "Sterling silver with cubic zirconia", pairsWellWith: "Dinner"),
            SuggestedGift(name: "Spa Day Package", category: .experience, price: 150 * multiplier,
                         description: "Full day couples spa with massage and facial", pairsWellWith: "Dinner"),
            SuggestedGift(name: "Concert Tickets", category: .experience, price: 130 * multiplier,
                         description: "Two tickets to her favorite artist", pairsWellWith: "Dinner"),
            SuggestedGift(name: "Weekend Getaway", category: .travel, price: 250 * multiplier,
                         description: "2-night boutique hotel stay", pairsWellWith: "Spa Day"),
            SuggestedGift(name: "Luxury Skincare Set", category: .skincare, price: 85 * multiplier,
                         description: "La Mer or Drunk Elephant gift set", pairsWellWith: "Candles"),
            SuggestedGift(name: "Silk Pajama Set", category: .clothing, price: 95 * multiplier,
                         description: "Premium silk PJs, monogrammable", pairsWellWith: "Skincare"),
            SuggestedGift(name: "Cashmere Scarf", category: .clothing, price: 110 * multiplier,
                         description: "100% cashmere in her favorite color", pairsWellWith: "Gloves"),
            SuggestedGift(name: "Dyson Airwrap", category: .tech, price: 200 * multiplier,
                         description: "Multi-styler for all hair types", pairsWellWith: "Skincare"),
            SuggestedGift(name: "Kindle Paperwhite", category: .tech, price: 80 * multiplier,
                         description: "Latest model, waterproof", pairsWellWith: "Book subscription"),
            SuggestedGift(name: "Book by Her Favorite Author", category: .books, price: 25 * multiplier,
                         description: "Signed first edition or special release", pairsWellWith: "Candle & blanket"),
            SuggestedGift(name: "Fine Dining Reservation", category: .food, price: 100 * multiplier,
                         description: "Tasting menu at a top-rated restaurant", pairsWellWith: "Flowers"),
            SuggestedGift(name: "Artisan Chocolate Box", category: .food, price: 40 * multiplier,
                         description: "Hand-crafted Belgian chocolates, 24pc", pairsWellWith: "Wine"),
            SuggestedGift(name: "Custom Photo Book", category: .custom, price: 60 * multiplier,
                         description: "Hardcover photo book of your best moments together", pairsWellWith: "Handwritten letter"),
            SuggestedGift(name: "Handwritten Love Letter", category: .custom, price: 5 * multiplier,
                         description: "On nice stationery with a wax seal", pairsWellWith: "Anything"),
            SuggestedGift(name: "Book of the Month Club", category: .subscription, price: 50 * multiplier,
                         description: "6-month subscription", pairsWellWith: "Kindle"),
            SuggestedGift(name: "Fresh Flower Subscription", category: .subscription, price: 45 * multiplier,
                         description: "Monthly premium bouquet delivery, 3 months", pairsWellWith: "Vase"),
            SuggestedGift(name: "Luxury Candle Set", category: .home, price: 55 * multiplier,
                         description: "Diptyque or Jo Malone trio", pairsWellWith: "Bath set"),
        ]

        // Boost gifts matching her interests
        if interests.contains("jewelry") {
            gifts.append(SuggestedGift(name: "Pearl Earrings", category: .jewelry, price: 90 * multiplier,
                                      description: "Freshwater pearl studs, classic elegance", pairsWellWith: "Necklace"))
        }
        if interests.contains("travel") {
            gifts.append(SuggestedGift(name: "Luxury Luggage Tag Set", category: .travel, price: 45 * multiplier,
                                      description: "Personalized leather luggage tags", pairsWellWith: "Weekend trip"))
        }
        if interests.contains("skincare") {
            gifts.append(SuggestedGift(name: "LED Face Mask", category: .skincare, price: 150 * multiplier,
                                      description: "Professional LED therapy mask", pairsWellWith: "Serum set"))
        }

        return gifts.sorted { $0.price < $1.price }
    }
}
