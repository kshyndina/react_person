import SwiftUI

@main
struct NeverForgetHerApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            if store.hasCompletedSetup {
                MainTabView()
                    .environmentObject(store)
            } else {
                SetupView()
                    .environmentObject(store)
            }
        }
    }
}

// MARK: - Setup / Onboarding

struct SetupView: View {
    @EnvironmentObject var store: AppStore
    @State private var name = ""
    @State private var birthday = Date()
    @State private var anniversary = Date()
    @State private var selectedInterests: Set<String> = []

    let interestOptions = ["jewelry", "flowers", "skincare", "books", "travel",
                           "cooking", "fashion", "tech", "fitness", "art", "music", "wine"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.pink)

                        Text("Never Forget Her")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Set up her profile so we can\nremind you and find perfect gifts")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Her Name", systemImage: "person.fill")
                            .font(.headline)
                        TextField("Name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }
                    .padding(.horizontal)

                    // Birthday
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Her Birthday", systemImage: "birthday.cake.fill")
                            .font(.headline)
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding(.horizontal)

                    // Anniversary
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your Anniversary", systemImage: "heart.circle.fill")
                            .font(.headline)
                        DatePicker("Anniversary", selection: $anniversary, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding(.horizontal)

                    // Interests
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Her Interests", systemImage: "sparkles")
                            .font(.headline)
                        Text("Select all that apply")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                            ForEach(interestOptions, id: \.self) { interest in
                                Button {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                } label: {
                                    Text(interest.capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedInterests.contains(interest) ? Color.pink : Color(.systemGray5))
                                        .foregroundStyle(selectedInterests.contains(interest) ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Save
                    Button {
                        store.partner.name = name.isEmpty ? "Her" : name
                        store.partner.birthday = birthday
                        store.partner.anniversary = anniversary
                        store.partner.interests = Array(selectedInterests)
                        // Update birthday and anniversary occasions
                        if let idx = store.occasions.firstIndex(where: { $0.name == "Her Birthday" }) {
                            store.occasions[idx].date = birthday
                        }
                        if let idx = store.occasions.firstIndex(where: { $0.name == "Anniversary" }) {
                            store.occasions[idx].date = anniversary
                        }
                        store.hasCompletedSetup = true
                        store.save()
                        NotificationScheduler.scheduleAll(occasions: store.occasions, partnerName: store.partner.name)
                    } label: {
                        Text("Let's Never Forget")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty ? Color.gray : Color.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            OccasionsView()
                .tabItem {
                    Label("Dates", systemImage: "calendar.badge.clock")
                }

            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "gift.fill")
                }

            GiftAdvisorView()
                .tabItem {
                    Label("Advisor", systemImage: "sparkles")
                }

            PartnerProfileView()
                .tabItem {
                    Label("Her", systemImage: "heart.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.pink)
    }
}
