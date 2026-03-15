import Foundation
import SwiftUI

@MainActor
final class Store: ObservableObject {
    @Published var partner: Partner {
        didSet { persist() }
    }
    @Published var occasions: [Occasion] {
        didSet { persist() }
    }
    @Published var setupDone: Bool {
        didSet { UserDefaults.standard.set(setupDone, forKey: "setupDone") }
    }

    init() {
        let ud = UserDefaults.standard
        self.setupDone = ud.bool(forKey: "setupDone")
        self.partner = Self.load("partner") ?? Partner.empty
        self.occasions = Self.load("occasions") ?? makeDefaultOccasions()
    }

    // MARK: - Persistence

    private func persist() {
        Self.save(partner, key: "partner")
        Self.save(occasions, key: "occasions")
    }

    private static func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Computed

    var upcoming: [Occasion] {
        occasions.sorted { $0.daysUntil < $1.daysUntil }
    }

    var allGifts: [Gift] { occasions.flatMap(\.gifts) }
    var totalBudget: Double { occasions.map(\.budget).reduce(0, +) }
    var totalSpent: Double { allGifts.filter(\.bought).map(\.price).reduce(0, +) }

    // MARK: - Mutations

    func addGift(_ gift: Gift, to occasionId: UUID) {
        guard let i = occasions.firstIndex(where: { $0.id == occasionId }) else { return }
        occasions[i].gifts.append(gift)
    }

    func toggleBought(_ giftId: UUID, in occasionId: UUID) {
        guard let oi = occasions.firstIndex(where: { $0.id == occasionId }),
              let gi = occasions[oi].gifts.firstIndex(where: { $0.id == giftId }) else { return }
        occasions[oi].gifts[gi].bought.toggle()
    }

    func removeGift(_ giftId: UUID, from occasionId: UUID) {
        guard let i = occasions.firstIndex(where: { $0.id == occasionId }) else { return }
        occasions[i].gifts.removeAll { $0.id == giftId }
    }

    func reset() {
        partner = Partner.empty
        occasions = makeDefaultOccasions()
        setupDone = false
    }
}
