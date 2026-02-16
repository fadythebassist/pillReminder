# Pill Reminder - Build Instructions

## Prerequisites

1. **Flutter SDK** (3.5.0+)
2. **Android SDK** (API 34+)
3. **Xcode** (15.0+ for iOS)
4. **Java JDK** (17+ for Android)

## Setup

### 1. Update local.properties

Edit `android/local.properties` with your SDK paths:

```properties
sdk.dir=/path/to/android/sdk
flutter.sdk=/path/to/flutter
```

### 2. Install Dependencies

```bash
cd pill_reminder
flutter pub get
```

## Android Build

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release AAB (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.aab`

### Release APK (for direct install)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## iOS Build

### Prerequisites

1. Open Xcode and configure signing
2. Update iOS deployment target to 15.0 in `ios/Podfile`

### Simulator Build

```bash
flutter build ios --simulator --no-codesign
```

### Release Archive

```bash
flutter build ios --release --no-codesign
```

### Upload to App Store

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as destination
3. Product → Archive
4. Distribute App → App Store Connect

## Running Tests

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

## Code Generation

If you modify Hive models:

```bash
flutter pub run build_runner build
```

## Build Configuration

### Android (android/app/build.gradle)

- **minSdkVersion**: 26 (Android 8.0)
- **targetSdkVersion**: 34 (Android 14)
- **compileSdkVersion**: 34

### iOS (ios/Podfile)

- **platform**: :ios, '15.0'

## Troubleshooting

### Android Build Issues

- Ensure JAVA_HOME points to JDK 17+
- Clean build: `flutter clean && flutter pub get`

### iOS Build Issues

- Update CocoaPods: `cd ios && pod install --repo-update`
- Ensure Xcode command line tools are installed

### Notification Issues (Android 13+)

- Ensure `POST_NOTIFICATIONS` permission is granted
- Check notification channel settings
