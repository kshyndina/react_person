import SwiftUI

@main
struct NeverForgetHerApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            Group {
                if store.setupDone {
                    MainTabs()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
        }
    }
}

// MARK: - Tabs

struct MainTabs: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            OccasionsView()
                .tag(0)
                .tabItem { Label("Dates", systemImage: "calendar") }

            WishlistView()
                .tag(1)
                .tabItem { Label("Gifts", systemImage: "gift") }

            GiftAdvisorView()
                .tag(2)
                .tabItem { Label("Ideas", systemImage: "wand.and.stars") }

            PartnerProfileView()
                .tag(3)
                .tabItem { Label("Her", systemImage: "heart") }

            SettingsView()
                .tag(4)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .tint(.pink)
    }
}

// MARK: - Onboarding

struct OnboardingView: View {
    @EnvironmentObject var store: Store
    @State private var step = 0
    @State private var name = ""
    @State private var birthday = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 15))!
    @State private var anniversary = Date()
    @State private var picked: Set<String> = []

    private let interests = [
        "Jewelry", "Flowers", "Skincare", "Books",
        "Travel", "Cooking", "Fashion", "Tech",
        "Fitness", "Art", "Music", "Wine"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Progress
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i <= step ? Color.pink : Color(.systemGray4))
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)

            TabView(selection: $step) {
                // Step 1: Name
                stepView {
                    VStack(spacing: 24) {
                        stepIcon("heart.text.square.fill")
                        stepTitle("What's her name?")
                        TextField("Her name", text: $name)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 40)
                    }
                }
                .tag(0)

                // Step 2: Dates
                stepView {
                    VStack(spacing: 24) {
                        stepIcon("calendar.badge.clock")
                        stepTitle("Important dates")

                        VStack(spacing: 16) {
                            DatePicker("Her Birthday", selection: $birthday, displayedComponents: .date)
                            DatePicker("Your Anniversary", selection: $anniversary, displayedComponents: .date)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .tag(1)

                // Step 3: Interests
                stepView {
                    VStack(spacing: 24) {
                        stepIcon("sparkles")
                        stepTitle("What does she love?")

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(interests, id: \.self) { item in
                                let on = picked.contains(item)
                                Button {
                                    if on { picked.remove(item) } else { picked.insert(item) }
                                } label: {
                                    Text(item)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(on ? Color.pink : Color(.systemGray6))
                                        .foregroundStyle(on ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: step)

            // Button
            Button {
                if step < 2 {
                    step += 1
                } else {
                    finishSetup()
                }
            } label: {
                Text(step < 2 ? "Continue" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(buttonDisabled ? Color(.systemGray4) : Color.pink)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(buttonDisabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var buttonDisabled: Bool {
        step == 0 && name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func finishSetup() {
        store.partner = Partner(
            name: name.trimmingCharacters(in: .whitespaces),
            birthday: birthday,
            anniversary: anniversary,
            interests: picked.map { $0.lowercased() },
            sizes: .empty
        )
        // Sync dates into occasions
        if let i = store.occasions.firstIndex(where: { $0.name == "Her Birthday" }) {
            store.occasions[i].date = birthday
        }
        if let i = store.occasions.firstIndex(where: { $0.name == "Anniversary" }) {
            store.occasions[i].date = anniversary
        }
        store.setupDone = true
        Notifier.scheduleAll(store.occasions, name: name)
    }

    @ViewBuilder
    private func stepView(@ViewBuilder content: () -> some View) -> some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }

    private func stepIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 48))
            .foregroundStyle(.pink)
    }

    private func stepTitle(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
    }
}
