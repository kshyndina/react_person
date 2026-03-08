# Phone App Analyzer - Native iOS (SwiftUI)

A native iOS app that analyzes installed applications for security, privacy, usage insights, and subscription tracking.

## Requirements

- macOS with Xcode 15+ installed
- iOS 17.0+ deployment target
- Apple Developer account (for device testing)

## Setup in Xcode

1. **Open Xcode** → File → New → Project
2. Select **iOS → App**
3. Configure:
   - Product Name: `PhoneAppAnalyzer`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 17.0**
4. Click **Create**

5. **Delete** the auto-generated `ContentView.swift` file

6. **Copy all `.swift` files** from this `PhoneAppAnalyzer/` folder into your Xcode project:
   - `PhoneApp.swift` — Data models and 19 sample apps
   - `AppState.swift` — Shared observable state
   - `PhoneAppAnalyzerApp.swift` — App entry point, welcome screen, tab navigation
   - `DashboardView.swift` — Analytics dashboard with charts
   - `AllAppsView.swift` — Browse/search/filter/sort all apps
   - `SubscriptionsView.swift` — Subscription cost tracking
   - `ManageView.swift` — Delete and restore apps
   - `PrivacyView.swift` — Privacy score and permission analysis
   - `SettingsView.swift` — Focus modes, toggles, sliders, RGB controls

7. **Important**: In `PhoneAppAnalyzerApp.swift`, the `@main` attribute marks the app entry point. If Xcode created its own app file, delete it or remove its `@main`.

8. **Build & Run** (Cmd + R) on Simulator or your device.

## Features

| Tab | What it does |
|-----|-------------|
| **Dashboard** | Summary stats, security alerts, top-5 bar charts (screen time, battery, data, size, permissions), category breakdown |
| **Apps** | Search bar, category filter chips, 6 sort options, expandable app cards with full details and color-coded permissions |
| **Subscriptions** | Monthly/yearly cost totals, paid vs free breakdown, renewal dates |
| **Manage** | Delete apps with confirmation, restore deleted apps, storage savings tracker |
| **Privacy** | Privacy score (0-100), excessive permissions list, location tracking apps, microphone access apps |
| **Settings** | 6 Focus modes, 10 quick toggles, brightness/volume/text sliders, Night Shift, True Tone, RGB color mixer |

## Architecture

- **SwiftUI** declarative UI
- **@StateObject / @EnvironmentObject** for shared state
- **Custom `FlowLayout`** (iOS 16+ Layout protocol) for permission tags
- No external dependencies — pure Apple frameworks
