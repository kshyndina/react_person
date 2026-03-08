"""
CLI entry point for the iOS Shortcuts Generator.

Usage:
    python -m shortcuts_generator list
    python -m shortcuts_generator generate <template> [--output <dir>]
    python -m shortcuts_generator generate --all [--output <dir>]
    python -m shortcuts_generator custom --name "My Shortcut" --actions '...'
"""

import argparse
import sys
from pathlib import Path

from .engine import Shortcut
from .templates import TEMPLATES


def cmd_list(args: argparse.Namespace) -> None:
    print("\nAvailable shortcut templates:\n")
    print(f"  {'Template':<25} Description")
    print(f"  {'─' * 25} {'─' * 45}")
    for name, (_, desc) in sorted(TEMPLATES.items()):
        print(f"  {name:<25} {desc}")
    print(f"\n  Total: {len(TEMPLATES)} templates\n")


def cmd_generate(args: argparse.Namespace) -> None:
    output_dir = Path(args.output)

    if args.all:
        templates_to_build = list(TEMPLATES.keys())
    else:
        templates_to_build = [args.template]

    for template_name in templates_to_build:
        if template_name not in TEMPLATES:
            print(f"Error: Unknown template '{template_name}'")
            print(f"Run 'python -m shortcuts_generator list' to see available templates.")
            sys.exit(1)

        factory, desc = TEMPLATES[template_name]
        shortcut = factory()
        out_path = shortcut.save(output_dir / f"{template_name}.shortcut")
        print(f"  Created: {out_path}  ({desc})")

    print(f"\nGenerated {len(templates_to_build)} shortcut(s) in {output_dir}/")
    print("\nNext steps:")
    print("  1. Transfer .shortcut files to your iPhone (AirDrop, iCloud, email)")
    print("  2. On macOS, sign them first: shortcuts sign -i file.shortcut -o signed.shortcut")
    print("  3. On iOS 14 or earlier, unsigned files can be imported directly")
    print()


def cmd_custom(args: argparse.Namespace) -> None:
    """Build a quick custom shortcut from CLI flags."""
    sc = Shortcut(args.name)

    if args.alert:
        sc.show_alert(args.name, args.alert)
    if args.open_url:
        sc.open_url(args.open_url)
    if args.open_settings:
        sc.open_settings_url(args.open_settings)
    if args.notification:
        sc.show_notification(args.name, args.notification)
    if args.low_power:
        sc.set_low_power_mode(True)
    if args.dark_mode:
        sc.set_appearance(dark=True)
    if args.brightness is not None:
        sc.set_brightness(args.brightness)

    output_dir = Path(args.output)
    safe_name = args.name.lower().replace(" ", "-")
    out_path = sc.save(output_dir / f"{safe_name}.shortcut")
    print(f"  Created: {out_path}")
    print(f"  Actions: {len(sc.actions)}")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="shortcuts_generator",
        description="Generate Apple Shortcuts (.shortcut) files for iOS automation",
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # list
    subparsers.add_parser("list", help="List all available shortcut templates")

    # generate
    gen_parser = subparsers.add_parser("generate", help="Generate shortcut(s) from templates")
    gen_parser.add_argument("template", nargs="?", help="Template name to generate")
    gen_parser.add_argument("--all", action="store_true", help="Generate all templates")
    gen_parser.add_argument("--output", "-o", default="output", help="Output directory (default: output)")

    # custom
    custom_parser = subparsers.add_parser("custom", help="Build a quick custom shortcut")
    custom_parser.add_argument("--name", required=True, help="Shortcut name")
    custom_parser.add_argument("--alert", help="Show an alert with this message")
    custom_parser.add_argument("--open-url", help="Open a URL")
    custom_parser.add_argument("--open-settings", help="Open a Settings URL (prefs:root=...)")
    custom_parser.add_argument("--notification", help="Show a notification")
    custom_parser.add_argument("--low-power", action="store_true", help="Enable Low Power Mode")
    custom_parser.add_argument("--dark-mode", action="store_true", help="Enable Dark Mode")
    custom_parser.add_argument("--brightness", type=float, help="Set brightness (0.0 - 1.0)")
    custom_parser.add_argument("--output", "-o", default="output", help="Output directory (default: output)")

    args = parser.parse_args()

    if args.command == "list":
        cmd_list(args)
    elif args.command == "generate":
        if not args.template and not args.all:
            gen_parser.error("Provide a template name or use --all")
        cmd_generate(args)
    elif args.command == "custom":
        cmd_custom(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
