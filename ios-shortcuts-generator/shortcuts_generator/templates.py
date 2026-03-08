"""
Pre-built shortcut templates for common iOS automation tasks.

Each function returns a fully constructed Shortcut object that can be
saved directly to a .shortcut file.
"""

from .engine import IconColor, IconGlyph, Shortcut


# ── 1. Close All Apps / App Cleanup ──────────────────────────────

def close_all_apps() -> Shortcut:
    """
    Prompts the user, then guides them through closing background apps.
    iOS doesn't allow programmatic app killing, so this walks the user
    through the process and offers to disable Background App Refresh.
    """
    sc = Shortcut("Close All Apps", color=IconColor.RED, glyph=IconGlyph.TRASH)
    sc.comment("Close All Apps - Guides you through cleaning up running apps")

    sc.show_alert(
        "Close Background Apps",
        "This shortcut will help you clean up background apps.\n\n"
        "Step 1: Swipe up from bottom and hold (or double-click Home)\n"
        "Step 2: Swipe up on each app card to close it\n\n"
        "After you're done, tap OK to continue.",
        show_cancel=True,
    )

    # Offer to disable background app refresh
    sc.open_settings_url("prefs:root=General&path=AUTO_CONTENT_DOWNLOAD")
    sc.wait(1)

    sc.show_notification(
        "Apps Cleaned Up",
        "Background apps guidance complete. Consider disabling Background App Refresh for apps you rarely use.",
    )

    return sc


# ── 2. Organize Home Screen ─────────────────────────────────────

def organize_home_screen() -> Shortcut:
    """
    Provides a guided workflow for organizing your iOS home screen.
    Opens relevant settings and gives tips.
    """
    sc = Shortcut("Organize Home Screen", color=IconColor.GREEN, glyph=IconGlyph.APP_GRID)
    sc.comment("Organize Home Screen - Step-by-step home screen cleanup")

    _, menu_id = sc.choose_from_menu(
        "What would you like to organize?",
        ["Reset Home Screen Layout", "Manage App Library", "Remove Unused Apps", "Set Up Focus Filters"],
    )

    # Case 1: Reset Home Screen Layout
    sc.menu_case(menu_id, 0)
    sc.show_alert(
        "Reset Home Screen",
        "This will open Settings > General > Transfer or Reset.\n"
        "Choose 'Reset Home Screen Layout' to alphabetically sort all apps.",
        show_cancel=True,
    )
    sc.open_settings_url("prefs:root=General&path=Reset")

    # Case 2: App Library
    sc.menu_case(menu_id, 1)
    sc.show_alert(
        "App Library Tips",
        "1. Swipe left past your last home screen page\n"
        "2. Apps are auto-organized into categories\n"
        "3. Long-press any app to move it to home screen\n"
        "4. Use the search bar at top to find any app\n\n"
        "Tip: Go to Settings > Home Screen & App Library to configure new app downloads.",
        show_cancel=False,
    )
    sc.open_settings_url("prefs:root=HOME_SCREEN_DOCK")

    # Case 3: Remove Unused Apps
    sc.menu_case(menu_id, 2)
    sc.show_alert(
        "Offload Unused Apps",
        "This will open iPhone Storage settings.\n"
        "Enable 'Offload Unused Apps' to automatically remove apps you haven't used recently (keeps data).",
        show_cancel=True,
    )
    sc.open_settings_url("prefs:root=General&path=STORAGE_MGMT")

    # Case 4: Focus Filters
    sc.menu_case(menu_id, 3)
    sc.show_alert(
        "Focus Home Screen Filters",
        "You can customize which home screen pages appear for each Focus mode.\n\n"
        "1. Go to Settings > Focus\n"
        "2. Select a Focus (e.g., Work)\n"
        "3. Tap 'Home Screen'\n"
        "4. Choose which pages to show",
        show_cancel=False,
    )
    sc.open_settings_url("prefs:root=FOCUS")

    sc.menu_end(menu_id)

    sc.show_notification("Home Screen", "Organization complete!")
    return sc


# ── 3. Battery Saver Mode ───────────────────────────────────────

def battery_saver() -> Shortcut:
    """
    Aggressively saves battery by toggling multiple settings.
    """
    sc = Shortcut("Battery Saver", color=IconColor.YELLOW, glyph=IconGlyph.BATTERY)
    sc.comment("Battery Saver - Maximize battery life by adjusting settings")

    sc.show_alert(
        "Battery Saver",
        "This will:\n"
        "- Enable Low Power Mode\n"
        "- Lower screen brightness\n"
        "- Enable Dark Mode\n"
        "- Turn off Bluetooth\n\n"
        "Continue?",
        show_cancel=True,
    )

    sc.set_low_power_mode(True)
    sc.set_brightness(0.25)
    sc.set_appearance(dark=True)
    sc.set_bluetooth(False)

    sc.show_notification(
        "Battery Saver Active",
        "Low Power Mode ON, Brightness lowered, Dark Mode ON, Bluetooth OFF",
    )

    return sc


# ── 4. Battery Saver OFF / Restore ──────────────────────────────

def battery_restore() -> Shortcut:
    """Restore normal settings after battery saving."""
    sc = Shortcut("Battery Restore", color=IconColor.GREEN, glyph=IconGlyph.BOLT)
    sc.comment("Restore normal battery/display settings")

    sc.set_low_power_mode(False)
    sc.set_brightness(0.65)
    sc.set_appearance(dark=False)
    sc.set_bluetooth(True)

    sc.show_notification("Settings Restored", "Back to normal settings.")
    return sc


# ── 5. Do Not Disturb / Focus Toggle ────────────────────────────

def focus_mode() -> Shortcut:
    """Toggle Do Not Disturb with options."""
    sc = Shortcut("Focus Mode", color=IconColor.PURPLE, glyph=IconGlyph.MOON)
    sc.comment("Quick Focus Mode toggle with options")

    _, menu_id = sc.choose_from_menu(
        "Focus Mode",
        ["Enable DND", "Disable DND", "Open Focus Settings"],
    )

    sc.menu_case(menu_id, 0)
    sc.set_do_not_disturb(True)
    sc.set_brightness(0.3)
    sc.show_notification("Focus Mode ON", "Do Not Disturb enabled, brightness lowered.")

    sc.menu_case(menu_id, 1)
    sc.set_do_not_disturb(False)
    sc.set_brightness(0.5)
    sc.show_notification("Focus Mode OFF", "Do Not Disturb disabled.")

    sc.menu_case(menu_id, 2)
    sc.open_settings_url("prefs:root=FOCUS")

    sc.menu_end(menu_id)
    return sc


# ── 6. Night Mode ───────────────────────────────────────────────

def night_mode() -> Shortcut:
    """Prepare device for bedtime: DND, low brightness, dark mode."""
    sc = Shortcut("Night Mode", color=IconColor.DARK_BLUE, glyph=IconGlyph.MOON)
    sc.comment("Night Mode - Prepare your device for sleep")

    sc.set_do_not_disturb(True)
    sc.set_brightness(0.1)
    sc.set_volume(0.1)
    sc.set_appearance(dark=True)

    sc.show_notification("Night Mode Active", "DND on, brightness & volume minimized, dark mode enabled.")
    return sc


# ── 7. Morning Routine ──────────────────────────────────────────

def morning_routine() -> Shortcut:
    """Wake up routine: disable DND, set brightness, light mode."""
    sc = Shortcut("Morning Routine", color=IconColor.ORANGE, glyph=IconGlyph.CLOCK)
    sc.comment("Morning Routine - Start your day")

    sc.set_do_not_disturb(False)
    sc.set_brightness(0.6)
    sc.set_volume(0.5)
    sc.set_appearance(dark=False)
    sc.set_wifi(True)

    sc.show_notification("Good Morning!", "DND off, brightness up, ready for the day.")
    return sc


# ── 8. Storage Cleanup ──────────────────────────────────────────

def storage_cleanup() -> Shortcut:
    """Guide user through cleaning up storage."""
    sc = Shortcut("Storage Cleanup", color=IconColor.TEAL, glyph=IconGlyph.TRASH)
    sc.comment("Storage Cleanup - Free up space on your device")

    _, menu_id = sc.choose_from_menu(
        "Storage Cleanup Options",
        ["View Storage Usage", "Clear Safari Data", "Manage Photos", "Offload Apps"],
    )

    sc.menu_case(menu_id, 0)
    sc.open_settings_url("prefs:root=General&path=STORAGE_MGMT")

    sc.menu_case(menu_id, 1)
    sc.show_alert(
        "Clear Safari Data",
        "This will open Safari settings where you can clear history and website data.",
        show_cancel=True,
    )
    sc.open_settings_url("prefs:root=SAFARI")

    sc.menu_case(menu_id, 2)
    sc.show_alert(
        "Photo Cleanup Tips",
        "1. Open Photos > Albums > Recently Deleted\n"
        "2. Tap 'Delete All' to permanently remove\n"
        "3. Review large videos in Albums > Videos\n"
        "4. Enable iCloud Photos to offload originals",
        show_cancel=False,
    )
    sc.open_app("com.apple.mobileslideshow", "Photos")

    sc.menu_case(menu_id, 3)
    sc.show_alert(
        "Offload Unused Apps",
        "Enable 'Offload Unused Apps' to automatically free up storage.\n"
        "App data is preserved so you can reinstall later.",
        show_cancel=True,
    )
    sc.open_settings_url("prefs:root=General&path=STORAGE_MGMT")

    sc.menu_end(menu_id)

    sc.show_notification("Storage Cleanup", "Done! Check your storage in Settings.")
    return sc


# ── 9. Privacy Lockdown ─────────────────────────────────────────

def privacy_lockdown() -> Shortcut:
    """Quick privacy hardening: airplane mode, clear clipboard."""
    sc = Shortcut("Privacy Lockdown", color=IconColor.DARK_GRAY, glyph=IconGlyph.SHIELD)
    sc.comment("Privacy Lockdown - Quick privacy mode")

    sc.show_alert(
        "Privacy Lockdown",
        "This will:\n"
        "- Enable Airplane Mode\n"
        "- Clear your clipboard\n"
        "- Lower brightness\n\n"
        "Use 'Privacy Restore' to undo.",
        show_cancel=True,
    )

    sc.set_airplane_mode(True)
    sc.clear_clipboard()
    sc.set_brightness(0.2)

    sc.show_notification("Privacy Lockdown Active", "Airplane mode on, clipboard cleared.")
    return sc


# ── 10. Privacy Restore ─────────────────────────────────────────

def privacy_restore() -> Shortcut:
    """Undo privacy lockdown."""
    sc = Shortcut("Privacy Restore", color=IconColor.GREEN, glyph=IconGlyph.SHIELD)
    sc.comment("Restore connectivity after Privacy Lockdown")

    sc.set_airplane_mode(False)
    sc.set_brightness(0.5)

    sc.show_notification("Privacy Restored", "Back online.")
    return sc


# ── 11. Share Wi-Fi / QR ────────────────────────────────────────

def wifi_qr_share() -> Shortcut:
    """Prompt for Wi-Fi credentials and generate a share-ready text."""
    sc = Shortcut("Share Wi-Fi", color=IconColor.LIGHT_BLUE, glyph=IconGlyph.BOLT)
    sc.comment("Share Wi-Fi - Generate shareable Wi-Fi info")

    sc.ask_for_input("What is the Wi-Fi network name (SSID)?", "Text")
    sc.set_variable("wifi_name")

    sc.ask_for_input("What is the Wi-Fi password?", "Text")
    sc.set_variable("wifi_pass")

    sc.text("WIFI:T:WPA;S:wifi_name;P:wifi_pass;;")
    sc.set_clipboard("Connect to Wi-Fi network. Check your clipboard for details.")

    sc.show_notification("Wi-Fi Info Ready", "Wi-Fi details copied to clipboard.")
    return sc


# ── 12. Device Info ──────────────────────────────────────────────

def device_info() -> Shortcut:
    """Show key device information."""
    sc = Shortcut("Device Info", color=IconColor.GRAY, glyph=IconGlyph.GEAR)
    sc.comment("Device Info - Quick system information")

    sc.get_device_details("Device Name")
    sc.set_variable("dev_name")

    sc.get_device_details("Device Model")
    sc.set_variable("dev_model")

    sc.get_device_details("System Version")
    sc.set_variable("dev_os")

    sc.get_battery_level()
    sc.set_variable("dev_battery")

    sc.show_result("Device: dev_name\nModel: dev_model\niOS: dev_os\nBattery: dev_battery%")

    return sc


# ── Registry of all templates ────────────────────────────────────

TEMPLATES: dict[str, tuple[callable, str]] = {
    "close-all-apps": (close_all_apps, "Guide through closing background apps"),
    "organize-home-screen": (organize_home_screen, "Organize and reset home screen layout"),
    "battery-saver": (battery_saver, "Enable aggressive battery saving"),
    "battery-restore": (battery_restore, "Restore normal settings after battery saving"),
    "focus-mode": (focus_mode, "Toggle Do Not Disturb with options"),
    "night-mode": (night_mode, "Prepare device for bedtime"),
    "morning-routine": (morning_routine, "Wake up routine - start your day"),
    "storage-cleanup": (storage_cleanup, "Guide through freeing up storage"),
    "privacy-lockdown": (privacy_lockdown, "Quick privacy hardening"),
    "privacy-restore": (privacy_restore, "Undo privacy lockdown"),
    "share-wifi": (wifi_qr_share, "Generate shareable Wi-Fi credentials"),
    "device-info": (device_info, "Show device name, model, OS, battery"),
}
