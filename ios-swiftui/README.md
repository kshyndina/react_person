# Never Forget Her - iOS App (SwiftUI)

A native iOS app for men who forget women's holidays, birthdays, and have trouble buying presents.

## What It Does

- Countdown timers to Valentine's Day, March 8th, her birthday, anniversary, Christmas, NYE
- Add custom occasions (Mother's Day, etc.)
- Wishlist manager — add her gift ideas with price, category, rating
- AI Gift Advisor — pick occasion + budget tier, get 3 curated gift combos with pairings
- Partner profile with her sizes (ring, clothing, shoe), interests
- Push notifications at 30, 14, 7, 3, 1, and 0 days before each occasion
- Panic-level urgency indicators so you know when to act

## Setup in Xcode

1. Open Xcode → File → New → Project → iOS → App
2. Product Name: `NeverForgetHer`, Interface: SwiftUI, Language: Swift, iOS 17+
3. Delete the auto-generated `ContentView.swift`
4. Copy all `.swift` files from `NeverForgetHer/` into the project
5. Add `Info.plist` to the project
6. Build & Run (Cmd+R)

## Files

| File | What |
|------|------|
| `Models.swift` | Partner, Occasion, GiftIdea, GiftCategory, BudgetTier, GiftEngine |
| `AppState.swift` | Shared store with persistence (UserDefaults) |
| `NeverForgetHerApp.swift` | @main entry, onboarding setup, tab navigation |
| `OccasionsView.swift` | Countdown cards, urgency colors, add custom occasions |
| `WishlistView.swift` | Per-occasion gift lists, add/purchase/track |
| `GiftAdvisorView.swift` | Budget picker, AI combo suggestions, add-to-wishlist |
| `PartnerProfileView.swift` | Her profile, sizes, interests, stats |
| `NotificationScheduler.swift` | Schedules iOS push notifications for all reminders |
| `SettingsView.swift` | Notification config, data stats, pro tips, reset |

## Budget Tiers

| Tier | Range |
|------|-------|
| Budget | Under $50 |
| Moderate | $50-150 |
| Generous | $150-300 |
| Splurge | $300-500 |
| All Out | $500+ |

Gift combos scale prices to your chosen tier and factor in her interests.

## No Dependencies

Pure SwiftUI + Apple frameworks. No pods, no SPM packages.
