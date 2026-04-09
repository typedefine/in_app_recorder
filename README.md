````markdown
# in_app_recorder

A Flutter plugin to, save it locally, and share the recorded video via native share sheets (social/messaging apps).

> ✅ Records *only your app*, not the entire device screen.
> ✅ Automatically shares video when recording ends.

---

## 🧰 Features

- Start/Stop app-only screen recording
- Add/remove red border overlay to indicate recording state
- Automatically share the video file once recorded

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_recorder:
````

---

## ⚙️ Android Setup

1. **Permissions** (Add in `android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_INTERNAL_STORAGE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

2. **Minimum SDK Version** (in `android/app/build.gradle`):

```gradle
defaultConfig {
  minSdkVersion 24
}
```

3. **Enable View Recording** (if using MediaProjection internally):

Some Android versions may require additional permission handling for screen capture APIs.

---

## 🍎 iOS Setup

1. **Permissions** (in `ios/Runner/Info.plist`):

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save the recorded screen to your photo library.</string>
```

2. **Minimum iOS Version**: `iOS 12.0+` recommended

3. **Post-processing**: iOS may require moving saved files to the app's document directory or Photos library for access.

---

## 🚀 Usage

```dart
import 'package:flutter_screen_recorder_overlay/in_app_recorder.dart';

final controller = ScreenRecorderController(videoExportPath: videoExportPath, fps:  8, shareMessage: "Hey this is the recorded video", shareVideo: true);

// Start recording
await controller.startRecording();

// Stop recording and share
await controller.stopRecordingAndShare();
```

---

## ✅ Add Red Border During Recording

```dart
// This automatically adds a red border overlay while recording
await controller.startRecording();
```

---

## 📂 Output

The recorded file is saved locally (`.mp4`) and then shared using native share sheets on both Android and iOS.

---

## 📱 Example

Check the `example/` directory for a fully working app.

---

## 🔐 Notes

* Android '9+ may require scoped storage handling
* Recording **starts after build**; consider a small delay before invoking

---

## 💬 Issues & Feedback

Feel free to [open an issue](https://github.com/J-Libraries/flutter_screen_capture/issues) or contribute a PR!

---

## 📝 License

MIT License © 2025 Nishant Mishra

```

### flutter pub publish --dry-run
### flutter pub publish