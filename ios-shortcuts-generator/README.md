# iOS Shortcuts Generator

Generate Apple Shortcuts (`.shortcut` files) programmatically with Python. No dependencies required beyond Python 3.10+ standard library.

Create shortcuts for app cleanup, home screen organization, battery saving, focus modes, privacy lockdown, and more — all from the command line or as a Python library.

## Quick Start

```bash
# List available templates
python -m shortcuts_generator list

# Generate all shortcuts
python -m shortcuts_generator generate --all

# Generate a specific shortcut
python -m shortcuts_generator generate battery-saver

# Build a custom shortcut
python -m shortcuts_generator custom --name "My Shortcut" --alert "Hello!" --dark-mode --brightness 0.3
```

## Available Templates

| Template | Description |
|---|---|
| `close-all-apps` | Guide through closing background apps |
| `organize-home-screen` | Reset home screen layout, manage App Library, offload apps |
| `battery-saver` | Low Power Mode + low brightness + dark mode + Bluetooth off |
| `battery-restore` | Undo battery saver settings |
| `focus-mode` | Toggle Do Not Disturb with options menu |
| `night-mode` | DND + minimal brightness/volume + dark mode |
| `morning-routine` | Disable DND, restore brightness, light mode |
| `storage-cleanup` | View storage, clear Safari data, manage photos, offload apps |
| `privacy-lockdown` | Airplane mode + clear clipboard |
| `privacy-restore` | Undo privacy lockdown |
| `share-wifi` | Generate shareable Wi-Fi credentials |
| `device-info` | Show device name, model, iOS version, battery level |

## Using as a Python Library

```python
from shortcuts_generator.engine import Shortcut, IconColor, IconGlyph

sc = Shortcut("My Custom Shortcut", color=IconColor.BLUE, glyph=IconGlyph.STAR)

sc.show_alert("Welcome", "This is my custom shortcut!")
sc.set_brightness(0.5)
sc.set_appearance(dark=True)
sc.set_do_not_disturb(True)
sc.show_notification("Done", "Settings applied!")

sc.save("output/my-shortcut.shortcut")
```

### Available Actions

The engine supports 40+ actions:

**Connectivity:** `set_wifi()`, `set_bluetooth()`, `set_airplane_mode()`, `set_cellular_data()`

**Display:** `set_brightness()`, `set_appearance()`, `set_wallpaper()`

**System:** `set_low_power_mode()`, `set_do_not_disturb()`, `set_volume()`, `vibrate()`

**UI:** `show_alert()`, `show_notification()`, `show_result()`, `ask_for_input()`, `choose_from_menu()`

**Flow Control:** `if_begin()` / `if_otherwise()` / `if_end()`, `repeat_begin()` / `repeat_end()`, `wait()`, `exit_shortcut()`

**Data:** `text()`, `set_variable()`, `get_variable()`, `set_clipboard()`, `clear_clipboard()`

**Navigation:** `open_app()`, `open_url()`, `open_settings_url()`, `open_x_callback()`

**Device:** `get_battery_level()`, `get_device_details()`, `get_current_location()`

**Other:** `comment()`, `speak_text()`, `play_sound()`, `run_shortcut()`, `delete_photos()`, `nothing()`

## Installing Shortcuts on iOS

### Option 1: AirDrop (Recommended)
1. Generate `.shortcut` files on your Mac
2. Sign them: `shortcuts sign -i file.shortcut -o signed.shortcut`
3. AirDrop the signed file to your iPhone
4. Tap to import into the Shortcuts app

### Option 2: iCloud Drive
1. Save `.shortcut` files to iCloud Drive
2. Open Files app on iPhone
3. Tap the `.shortcut` file to import

### Option 3: macOS `shortcuts` CLI
```bash
# Sign a shortcut
shortcuts sign -i battery-saver.shortcut -o battery-saver-signed.shortcut

# Install directly on macOS
shortcuts import battery-saver-signed.shortcut
```

### Signing Requirement
Starting with iOS 15 / macOS 12, shortcut files must be signed before they can be imported. Use the `shortcuts sign` CLI on macOS to sign generated files. On iOS 14 and earlier, unsigned files can be imported directly.

## Project Structure

```
ios-shortcuts-generator/
├── shortcuts_generator/
│   ├── __init__.py          # Package metadata
│   ├── __main__.py          # python -m entry point
│   ├── engine.py            # Core Shortcut builder (plist-based)
│   ├── cli.py               # CLI interface
│   └── templates.py         # Pre-built shortcut templates
├── output/                  # Generated .shortcut files
├── pyproject.toml           # Project config
└── README.md
```

## How It Works

Apple Shortcuts are stored as binary property list (plist) files. Each shortcut contains:

- **Metadata**: name, icon color/glyph, client version
- **Actions array**: each action has an identifier (`is.workflow.actions.*`) and parameters
- **Input content classes**: what types of input the shortcut accepts

This tool uses Python's built-in `plistlib` to construct valid plist structures and write them as binary `.shortcut` files. No external dependencies needed.

## License

MIT
