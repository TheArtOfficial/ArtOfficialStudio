import json
import sys
import os

# The settings you want to ensure exist
required_settings = {
    "VHS.AdvancedPreviews": "Always",
    "VHS.LatentPreview": True
}

def ensure_settings(settings_file):
    # First, load the existing JSON
    if os.path.exists(settings_file):
        with open(settings_file, "r", encoding="utf-8") as f:
            try:
                settings = json.load(f)
            except json.JSONDecodeError:
                print(f"Error: {settings_file} is not a valid JSON file!")
                sys.exit(1)
    else:
        settings = {}

    # Update settings (overwriting if necessary)
    updated = False
    for key, value in required_settings.items():
        if settings.get(key) != value:
            settings[key] = value
            updated = True

    # Write back only if there were changes
    if updated:
        with open(settings_file, "w", encoding="utf-8") as f:
            json.dump(settings, f, indent=4)
        print(f"{settings_file} updated.")
    else:
        print(f"{settings_file} already up to date.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 ensure_settings.py <path_to_settings.json>")
        sys.exit(1)
    
    settings_path = sys.argv[1]
    ensure_settings(settings_path)
