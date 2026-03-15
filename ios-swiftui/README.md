# Never Forget Her

A native iOS app for men who forget holidays, birthdays, and have trouble buying presents.

## Setup

1. **Xcode** → File → New → Project → iOS → App
2. Product Name: `NeverForgetHer`, SwiftUI, Swift, iOS 17+
3. Delete the generated `ContentView.swift`
4. Drag all `.swift` files + `Info.plist` from `NeverForgetHer/` into the project
5. Cmd+R

No dependencies. Pure SwiftUI.

## Files

| File | What |
|------|------|
| `Models.swift` | Data types, gift engine with 20+ items, budget scaling |
| `AppState.swift` | Observable store, UserDefaults persistence |
| `NeverForgetHerApp.swift` | Entry point, 3-step onboarding, tab bar |
| `OccasionsView.swift` | Countdown timeline, urgency colors, add custom |
| `WishlistView.swift` | Per-occasion gift lists, swipe to delete, buy toggle |
| `GiftAdvisorView.swift` | Pick occasion + budget, get 3 curated combos |
| `PartnerProfileView.swift` | Her profile, sizes, interests, stats |
| `NotificationScheduler.swift` | Push reminders at 30/14/7/3/1/0 days |
| `SettingsView.swift` | Notifications, data, survival guide |
