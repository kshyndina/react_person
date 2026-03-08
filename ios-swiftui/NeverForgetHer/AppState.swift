import Foundation
import SwiftUI

class AppStore: ObservableObject {
    @Published var partner: Partner
    @Published var occasions: [Occasion]
    @Published var hasCompletedSetup: Bool

    init() {
        // Load from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: "partner"),
           let saved = try? JSONDecoder().decode(Partner.self, from: data) {
            self.partner = saved
        } else {
            self.partner = Partner.sample
        }

        if let data = UserDefaults.standard.data(forKey: "occasions"),
           let saved = try? JSONDecoder().decode([Occasion].self, from: data) {
            self.occasions = saved
        } else {
            self.occasions = defaultOccasions()
        }

        self.hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
    }

    func save() {
        if let data = try? JSONEncoder().encode(partner) {
            UserDefaults.standard.set(data, forKey: "partner")
        }
        if let data = try? JSONEncoder().encode(occasions) {
            UserDefaults.standard.set(data, forKey: "occasions")
        }
        UserDefaults.standard.set(hasCompletedSetup, forKey: "hasCompletedSetup")
    }

    // Sorted by urgency
    var upcomingOccasions: [Occasion] {
        occasions.sorted { $0.daysUntil < $1.daysUntil }
    }

    var nextOccasion: Occasion? {
        upcomingOccasions.first
    }

    // All gift ideas across occasions
    var allGiftIdeas: [GiftIdea] {
        occasions.flatMap { $0.giftIdeas }
    }

    var totalBudget: Double {
        occasions.compactMap { $0.budget }.reduce(0, +)
    }

    var totalSpent: Double {
        allGiftIdeas.filter { $0.isPurchased }.reduce(0) { $0 + $1.priceEstimate }
    }

    func addGiftIdea(_ gift: GiftIdea, to occasionId: UUID) {
        if let idx = occasions.firstIndex(where: { $0.id == occasionId }) {
            occasions[idx].giftIdeas.append(gift)
            save()
        }
    }

    func removeGiftIdea(_ giftId: UUID, from occasionId: UUID) {
        if let idx = occasions.firstIndex(where: { $0.id == occasionId }) {
            occasions[idx].giftIdeas.removeAll { $0.id == giftId }
            save()
        }
    }

    func togglePurchased(_ giftId: UUID, in occasionId: UUID) {
        if let oIdx = occasions.firstIndex(where: { $0.id == occasionId }),
           let gIdx = occasions[oIdx].giftIdeas.firstIndex(where: { $0.id == giftId }) {
            occasions[oIdx].giftIdeas[gIdx].isPurchased.toggle()
            save()
        }
    }

    func addOccasion(_ occasion: Occasion) {
        occasions.append(occasion)
        save()
    }

    func deleteOccasion(_ id: UUID) {
        occasions.removeAll { $0.id == id }
        save()
    }
}
