import SwiftUI

@main
struct PhoneAppAnalyzerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Content View (Welcome / Main)

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.hasScanned {
            MainTabView()
        } else {
            WelcomeView()
        }
    }
}

// MARK: - Welcome / Scan View

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Phone icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 280)
                        .shadow(radius: 20)

                    VStack(spacing: 12) {
                        Image(systemName: "iphone")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                        if appState.isScanning {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .symbolEffect(.pulse)
                        }
                    }
                }

                Text("Phone App Analyzer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Analyze your installed apps for\nsecurity, privacy, and usage insights")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                if appState.isScanning {
                    VStack(spacing: 8) {
                        ProgressView(value: appState.scanProgress)
                            .tint(.white)
                            .frame(width: 250)

                        Text("Scanning \(Int(appState.scanProgress * Double(sampleApps.count))) of \(sampleApps.count) apps...")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                } else {
                    Button(action: { appState.startScan() }) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Scan My Phone")
                        }
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            AllAppsView()
                .tabItem {
                    Label("Apps", systemImage: "square.grid.2x2.fill")
                }

            SubscriptionsView()
                .tabItem {
                    Label("Subs", systemImage: "creditcard.fill")
                }

            ManageView()
                .tabItem {
                    Label("Manage", systemImage: "trash.fill")
                }

            PrivacyView()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
