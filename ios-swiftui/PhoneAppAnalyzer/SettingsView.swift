import SwiftUI

struct SettingsView: View {
    // Focus modes
    @State private var activeFocus: String? = nil

    // Quick settings
    @State private var wifiOn = true
    @State private var bluetoothOn = true
    @State private var cellularOn = true
    @State private var airplaneMode = false
    @State private var hotspotOn = false
    @State private var locationServices = true
    @State private var nfcOn = true
    @State private var notificationsOn = true
    @State private var autoRotate = true
    @State private var darkMode = false

    // Display settings
    @State private var brightness: Double = 75
    @State private var volume: Double = 50
    @State private var textSize: Double = 16
    @State private var nightShift = false
    @State private var trueTone = true

    // RGB
    @State private var red: Double = 100
    @State private var green: Double = 150
    @State private var blue: Double = 255

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    focusModes
                    quickSettings
                    displaySettings
                    rgbControls
                }
                .padding()
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Focus Modes

    private var focusModes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Focus Modes", systemImage: "moon.fill")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FocusButton(name: "Do Not Disturb", icon: "moon.fill", isActive: activeFocus == "dnd") {
                    activeFocus = activeFocus == "dnd" ? nil : "dnd"
                }
                FocusButton(name: "Sleep", icon: "bed.double.fill", isActive: activeFocus == "sleep") {
                    activeFocus = activeFocus == "sleep" ? nil : "sleep"
                }
                FocusButton(name: "Work", icon: "briefcase.fill", isActive: activeFocus == "work") {
                    activeFocus = activeFocus == "work" ? nil : "work"
                }
                FocusButton(name: "Personal", icon: "heart.fill", isActive: activeFocus == "personal") {
                    activeFocus = activeFocus == "personal" ? nil : "personal"
                }
                FocusButton(name: "Driving", icon: "car.fill", isActive: activeFocus == "driving") {
                    activeFocus = activeFocus == "driving" ? nil : "driving"
                }
                FocusButton(name: "Fitness", icon: "dumbbell.fill", isActive: activeFocus == "fitness") {
                    activeFocus = activeFocus == "fitness" ? nil : "fitness"
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    // MARK: - Quick Settings

    private var quickSettings: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Quick Settings", systemImage: "switch.2")
                .font(.headline)
                .padding(.bottom, 8)

            SettingsToggle(icon: "wifi", label: "Wi-Fi", isOn: $wifiOn)
            SettingsToggle(icon: "antenna.radiowaves.left.and.right", label: "Bluetooth", isOn: $bluetoothOn)
            SettingsToggle(icon: "antenna.radiowaves.left.and.right.circle", label: "Cellular Data", isOn: $cellularOn)
            SettingsToggle(icon: "airplane", label: "Airplane Mode", isOn: $airplaneMode)
            SettingsToggle(icon: "personalhotspot", label: "Personal Hotspot", isOn: $hotspotOn)
            SettingsToggle(icon: "location.fill", label: "Location Services", isOn: $locationServices)
            SettingsToggle(icon: "wave.3.right", label: "NFC", isOn: $nfcOn)
            SettingsToggle(icon: "bell.fill", label: "Notifications", isOn: $notificationsOn)
            SettingsToggle(icon: "rotate.right.fill", label: "Auto-Rotate", isOn: $autoRotate)
            SettingsToggle(icon: "moon.circle.fill", label: "Dark Mode", isOn: $darkMode)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    // MARK: - Display Settings

    private var displaySettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Display", systemImage: "display")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.yellow)
                    Text("Brightness")
                    Spacer()
                    Text("\(Int(brightness))%")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $brightness, in: 0...100)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(.blue)
                    Text("Volume")
                    Spacer()
                    Text("\(Int(volume))%")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $volume, in: 0...100)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundStyle(.purple)
                    Text("Text Size")
                    Spacer()
                    Text("\(Int(textSize))px")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $textSize, in: 10...28, step: 1)
            }

            SettingsToggle(icon: "moon.fill", label: "Night Shift", isOn: $nightShift)
            SettingsToggle(icon: "circle.lefthalf.filled", label: "True Tone", isOn: $trueTone)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    // MARK: - RGB Controls

    private var rgbControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("RGB Color", systemImage: "paintpalette.fill")
                .font(.headline)

            // Color preview
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: red / 255, green: green / 255, blue: blue / 255))
                .frame(height: 80)
                .overlay(
                    Text("R:\(Int(red)) G:\(Int(green)) B:\(Int(blue))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                )

            VStack(spacing: 12) {
                HStack {
                    Text("R").fontWeight(.bold).foregroundStyle(.red).frame(width: 20)
                    Slider(value: $red, in: 0...255)
                        .tint(.red)
                    Text("\(Int(red))").frame(width: 36).font(.caption)
                }
                HStack {
                    Text("G").fontWeight(.bold).foregroundStyle(.green).frame(width: 20)
                    Slider(value: $green, in: 0...255)
                        .tint(.green)
                    Text("\(Int(green))").frame(width: 36).font(.caption)
                }
                HStack {
                    Text("B").fontWeight(.bold).foregroundStyle(.blue).frame(width: 20)
                    Slider(value: $blue, in: 0...255)
                        .tint(.blue)
                    Text("\(Int(blue))").frame(width: 36).font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Focus Button

struct FocusButton: View {
    let name: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(name)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? Color.blue : Color(.systemGray5))
            .foregroundStyle(isActive ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Settings Toggle

struct SettingsToggle: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                Text(label)
            }
        }
        .padding(.vertical, 2)
    }
}
