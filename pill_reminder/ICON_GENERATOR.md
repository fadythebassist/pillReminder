# Pill Reminder - App Icon Generator Instructions

## Option 1: Using flutter_launcher_icons (Recommended)

### Step 1: Add Package

Add `flutter_launcher_icons` to dev_dependencies in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Step 2: Create Icon Configuration

Create a file `flutter_launcher_icons.yaml` in the project root:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/pill_icon.png"
  adaptive_icon_background: "#1976D2"
  adaptive_icon_foreground: "assets/icon/pill_icon_foreground.png"
  
  # Remove these two lines if not using adaptive icons
  # adaptive_icon_background: "#1976D2" (use solid color)
  # adaptive_icon_foreground: "assets/icon/pill_icon_foreground.png"
```

### Step 3: Create Assets Folder

```bash
mkdir -p assets/icon
```

### Step 4: Create a Simple Pill Icon

You can create a simple pill icon using any image editor:

1. **Size:** 1024x1024 pixels
2. **Format:** PNG with transparency
3. **Design:** A simple capsule/pill shape in blue (#1976D2)

### Step 5: Generate Icons

```bash
flutter pub run flutter_launcher_icons
```

This will generate:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## Option 2: Manual Icon Generation

### Android Icons

Create icons for these density folders:

```
android/app/src/main/res/
├── mipmap-mdpi/    (48x48)
├── mipmap-hdpi/    (72x72)
├── mipmap-xhdpi/   (96x96)
├── mipmap-xxhdpi/  (144x144)
├── mipmap-xxxhdpi/ (192x192)
└── mipmap-anydpi-v26/ (adaptive icons)
```

### iOS Icons

Add icons to `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:

Required sizes:
- 20x20 (2x, 3x)
- 29x29 (2x, 3x)
- 40x40 (2x, 3x)
- 60x60 (2x, 3x)
- 76x76 (2x)
- 83.5x83.5 (2x)
- 1024x1024 (App Store)

---

## Simple Icon Design (Create in Canva/Figma)

1. Create a 1024x1024 canvas
2. Add a rounded rectangle (pill shape)
3. Fill with color #1976D2 (primary blue)
4. Optionally add a white line分割 pill in half
5. Export as PNG

---

## Testing Icons

After generation, test on:

- **Android:** Different API levels (26+)
- **iOS:** Different device sizes

---

## Troubleshooting

If icons don't appear:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the app

For iOS, you may need to open Xcode and verify the asset catalog is correctly configured.
