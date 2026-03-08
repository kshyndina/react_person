"""
Core engine for generating Apple Shortcuts (.shortcut) files.

Apple Shortcuts are stored as binary plist files with a specific schema.
This engine provides a Pythonic API to build shortcuts action-by-action
and export them as .shortcut files that can be imported via AirDrop,
iCloud, or the `shortcuts` CLI on macOS.

Note: On iOS 15+ / macOS 12+, shortcuts must be signed before import.
On macOS, use: `shortcuts sign -i input.shortcut -o signed.shortcut`
"""

import plistlib
import uuid
from pathlib import Path
from typing import Any


def _uuid() -> str:
    return str(uuid.uuid4()).upper()


# --- Icon color and glyph constants ---

class IconColor:
    RED = 4271083519
    ORANGE = 4274264319
    YELLOW = 4274750975
    GREEN = 4292093695
    TEAL = 431817727
    LIGHT_BLUE = 1440408063
    BLUE = 463140863
    DARK_BLUE = 946986751
    PURPLE = 2071128575
    PINK = 3679049983
    DARK_GRAY = 2846468607
    GRAY = 3031607807


class IconGlyph:
    MAGIC_WAND = 59771
    GEAR = 59751
    TRASH = 59768
    FOLDER = 59737
    BATTERY = 59694
    MOON = 59545
    BELL = 59697
    SCREEN = 59752
    PHONE = 59753
    CLOCK = 59714
    STAR = 59764
    BOLT = 59698
    SHIELD = 59760
    HOME = 59742
    APP_GRID = 59688


class Shortcut:
    """Builder for an Apple Shortcut."""

    def __init__(
        self,
        name: str,
        color: int = IconColor.BLUE,
        glyph: int = IconGlyph.MAGIC_WAND,
        client_version: int = 900,
        min_version: int = 900,
    ):
        self.name = name
        self.color = color
        self.glyph = glyph
        self.client_version = client_version
        self.min_version = min_version
        self.actions: list[dict[str, Any]] = []
        self.input_content_classes: list[str] = []

    # ── Action helpers ──────────────────────────────────────────────

    def add_action(self, identifier: str, parameters: dict[str, Any] | None = None) -> "Shortcut":
        action: dict[str, Any] = {"WFWorkflowActionIdentifier": identifier}
        if parameters:
            action["WFWorkflowActionParameters"] = parameters
        self.actions.append(action)
        return self

    def comment(self, text: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.comment", {"WFCommentActionText": text})

    def show_alert(self, title: str, message: str, show_cancel: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.alert", {
            "WFAlertActionTitle": title,
            "WFAlertActionMessage": message,
            "WFAlertActionCancelButtonShown": show_cancel,
        })

    def show_notification(self, title: str, body: str, play_sound: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.notification", {
            "WFNotificationActionTitle": title,
            "WFNotificationActionBody": body,
            "WFNotificationActionSound": play_sound,
        })

    def show_result(self, text: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.showresult", {
            "Text": _make_text(text),
        })

    def ask_for_input(self, prompt: str, input_type: str = "Text", default: str = "") -> "Shortcut":
        params: dict[str, Any] = {
            "WFAskActionPrompt": prompt,
            "WFInputType": input_type,
        }
        if default:
            params["WFAskActionDefaultAnswer"] = default
        return self.add_action("is.workflow.actions.ask", params)

    def open_app(self, app_bundle_id: str, app_name: str = "") -> "Shortcut":
        return self.add_action("is.workflow.actions.openapp", {
            "WFAppIdentifier": app_bundle_id,
            "WFAppName": app_name or app_bundle_id,
        })

    def open_url(self, url: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.openurl", {
            "WFInput": _make_text(url),
        })

    def open_settings_url(self, url: str) -> "Shortcut":
        """Open a prefs:// or App-Prefs:// URL to jump into Settings."""
        return self.open_url(url)

    def wait(self, seconds: float) -> "Shortcut":
        return self.add_action("is.workflow.actions.delay", {
            "WFDelayTime": seconds,
        })

    def vibrate(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.vibrate")

    def set_brightness(self, level: float) -> "Shortcut":
        return self.add_action("is.workflow.actions.setbrightness", {
            "WFBrightness": level,
        })

    def set_volume(self, level: float) -> "Shortcut":
        return self.add_action("is.workflow.actions.setvolume", {
            "WFVolume": level,
        })

    def set_low_power_mode(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.lowpowermode", {
            "OnValue": enabled,
        })

    def set_airplane_mode(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.airplanemode.set", {
            "OnValue": enabled,
        })

    def set_bluetooth(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.bluetooth.set", {
            "OnValue": enabled,
        })

    def set_wifi(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.wifi.set", {
            "OnValue": enabled,
        })

    def set_cellular_data(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.cellulardata.set", {
            "OnValue": enabled,
        })

    def set_do_not_disturb(self, enabled: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.dnd.set", {
            "Enabled": enabled,
        })

    def set_appearance(self, dark: bool = True) -> "Shortcut":
        style = "dark" if dark else "light"
        return self.add_action("is.workflow.actions.appearance", {
            "WFAppearance": style,
        })

    def set_wallpaper(self, photo_variable: str | None = None) -> "Shortcut":
        params: dict[str, Any] = {}
        if photo_variable:
            params["WFInput"] = photo_variable
        return self.add_action("is.workflow.actions.setwallpaper", params)

    def get_battery_level(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.getbatterylevel")

    def get_device_details(self, detail: str = "Device Name") -> "Shortcut":
        return self.add_action("is.workflow.actions.getdevicedetails", {
            "WFDeviceDetail": detail,
        })

    def set_variable(self, name: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.setvariable", {
            "WFVariableName": name,
        })

    def get_variable(self, name: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.getvariable", {
            "WFVariable": {"Value": {"VariableName": name, "Type": "Variable"}, "WFSerializationType": "WFTextTokenAttachment"},
        })

    def text(self, text_content: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.gettext", {
            "WFTextActionText": _make_text(text_content),
        })

    def choose_from_menu(self, prompt: str, options: list[str]) -> tuple["Shortcut", str]:
        group_id = _uuid()
        self.add_action("is.workflow.actions.choosefrommenu", {
            "WFMenuPrompt": prompt,
            "WFMenuItems": options,
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 0,
        })
        return self, group_id

    def menu_case(self, group_id: str, index: int) -> "Shortcut":
        return self.add_action("is.workflow.actions.choosefrommenu", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 1,
            "WFMenuItemTitle": index,
        })

    def menu_end(self, group_id: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.choosefrommenu", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 2,
        })

    def if_begin(self, condition: int = 0, value: Any = None) -> tuple["Shortcut", str]:
        group_id = _uuid()
        params: dict[str, Any] = {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 0,
            "WFCondition": condition,
        }
        if value is not None:
            params["WFNumberValue"] = value
        self.add_action("is.workflow.actions.conditional", params)
        return self, group_id

    def if_otherwise(self, group_id: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.conditional", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 1,
        })

    def if_end(self, group_id: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.conditional", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 2,
        })

    def repeat_begin(self, count: int) -> tuple["Shortcut", str]:
        group_id = _uuid()
        self.add_action("is.workflow.actions.repeat.count", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 0,
            "WFRepeatCount": count,
        })
        return self, group_id

    def repeat_end(self, group_id: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.repeat.count", {
            "GroupingIdentifier": group_id,
            "WFControlFlowMode": 2,
        })

    def run_shortcut(self, shortcut_name: str, show_while_running: bool = True) -> "Shortcut":
        return self.add_action("is.workflow.actions.runworkflow", {
            "WFWorkflowName": shortcut_name,
            "WFShowWorkflow": show_while_running,
        })

    def speak_text(self, text: str | None = None) -> "Shortcut":
        params: dict[str, Any] = {}
        if text:
            params["WFText"] = _make_text(text)
        return self.add_action("is.workflow.actions.speaktext", params)

    def play_sound(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.playsound")

    def exit_shortcut(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.exit")

    def nothing(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.nothing")

    def open_x_callback(self, url: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.openxcallbackurl", {
            "WFXCallbackURL": url,
        })

    def delete_photos(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.deletephotos")

    def clear_clipboard(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.setclipboard", {
            "WFInput": _make_text(""),
        })

    def set_clipboard(self, text: str) -> "Shortcut":
        return self.add_action("is.workflow.actions.setclipboard", {
            "WFInput": _make_text(text),
        })

    def get_current_location(self) -> "Shortcut":
        return self.add_action("is.workflow.actions.getcurrentlocation")

    # ── Build & export ─────────────────────────────────────────────

    def to_plist_dict(self) -> dict[str, Any]:
        return {
            "WFWorkflowClientVersion": self.client_version,
            "WFWorkflowClientRelease": "4.0",
            "WFWorkflowMinimumClientVersion": self.min_version,
            "WFWorkflowMinimumClientVersionString": "900",
            "WFWorkflowName": self.name,
            "WFWorkflowIcon": {
                "WFWorkflowIconStartColor": self.color,
                "WFWorkflowIconGlyphNumber": self.glyph,
            },
            "WFWorkflowActions": self.actions,
            "WFWorkflowInputContentItemClasses": self.input_content_classes or [
                "WFAppStoreAppContentItem",
                "WFArticleContentItem",
                "WFContactContentItem",
                "WFDateContentItem",
                "WFEmailAddressContentItem",
                "WFGenericFileContentItem",
                "WFImageContentItem",
                "WFiTunesProductContentItem",
                "WFLocationContentItem",
                "WFDCMapsLinkContentItem",
                "WFAVAssetContentItem",
                "WFPDFContentItem",
                "WFPhoneNumberContentItem",
                "WFRichTextContentItem",
                "WFSafariWebPageContentItem",
                "WFStringContentItem",
                "WFURLContentItem",
            ],
            "WFWorkflowImportQuestions": [],
            "WFWorkflowTypes": ["NCWidget", "WatchKit"],
        }

    def save(self, path: str | Path) -> Path:
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        data = plistlib.dumps(self.to_plist_dict(), fmt=plistlib.FMT_BINARY)
        path.write_bytes(data)
        return path

    def __repr__(self) -> str:
        return f"Shortcut(name={self.name!r}, actions={len(self.actions)})"


# ── Utility ────────────────────────────────────────────────────────

def _make_text(text: str) -> dict[str, Any]:
    """Wrap a plain string in the WFTextTokenString format."""
    return {
        "Value": {
            "attachmentsByRange": {},
            "string": text,
        },
        "WFSerializationType": "WFTextTokenString",
    }
