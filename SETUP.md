# 🎵 Music App — Local Setup Guide

Step-by-step instructions to build and run this Flutter app on your laptop.

---

## Prerequisites

| Tool             | Required Version       | Install (Arch Linux)                         |
| ---------------- | ---------------------- | -------------------------------------------- |
| **Flutter SDK**  | ≥ 3.0.0                | Already installed at `~/flutter`              |
| **Java (JDK)**   | 17                     | `sudo pacman -S jdk17-openjdk`               |
| **Android SDK**  | Platform 34            | Via `sdkmanager` (see below)                  |
| **ADB**          | Latest                 | `sudo pacman -S android-tools`               |
| **Chrome**       | Latest *(for web run)* | `sudo pacman -S chromium`                    |

---

## 1 — Add Flutter to PATH

### For Fish Shell (your current shell):
Run this single command in your terminal (it updates your PATH immediately and permanently):
```fish
fish_add_path ~/flutter/bin
```

### For Bash / Zsh:
```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify:
```bash
flutter --version
```

---

## 2 — Install Dependencies

```bash
cd ~/Desktop/Desktop/Android/1-MusicApp-Flutter
flutter pub get
```

---

## 3 — Run on Android (Physical Device)

### a) Enable USB Debugging on your phone
1. Go to **Settings → About Phone** → tap **Build Number** 7 times to enable Developer Options.
2. Go to **Settings → Developer Options** → enable **USB Debugging**.

### b) Connect & verify
```bash
adb devices
```
You should see your device listed. Accept the prompt on your phone if asked.

### c) Run the app
```bash
flutter run
```
Flutter will auto-detect the connected device, build the APK, and install it.

---

## 4 — Run on Android Emulator

### a) Set up Android SDK (if not already done)
```bash
# Set env vars (add to ~/.zshrc for persistence)
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Accept licenses & install platform tools
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "system-images;android-34;google_apis;x86_64"
```

### b) Create an emulator
```bash
avdmanager create avd -n Pixel_6 -k "system-images;android-34;google_apis;x86_64" --device "pixel_6"
```

### c) Launch emulator & run
```bash
emulator -avd Pixel_6 &
flutter run
```

---

## 5 — Run on Linux Desktop

```bash
flutter run -d linux
```

> **Note:** Requires GTK development libraries. Install if missing:
> ```bash
> sudo pacman -S gtk3 clang cmake ninja pkg-config
> ```

---

## 6 — Run as Web App (Port 8080)

### Option A: Web Server (Headless, open in any browser)
Starts a local web server on port 8080 without auto-launching a browser:
```fish
flutter run -d web-server --web-port 8080 --web-hostname localhost
```
Then navigate to **http://localhost:8080** in your browser.

*(Use `--web-hostname 0.0.0.0` if you want other devices on your local network to access it).*

---

### Option B: Auto-launch in Brave Browser
Flutter looks for Chrome by default. Since you have Brave installed, tell Flutter where Brave is:
```fish
set -Ux CHROME_EXECUTABLE /usr/bin/brave
```
*(This has already been configured for you).*

Now run directly on port 8080:
```fish
flutter run -d chrome --web-port 8080
```

---

## Quick Reference

| Command                        | What it does                            |
| ------------------------------ | --------------------------------------- |
| `flutter doctor`               | Check environment & show missing deps   |
| `flutter pub get`              | Install Dart/Flutter dependencies       |
| `flutter run`                  | Build & run on connected device         |
| `flutter run -d chrome`        | Run in Chrome browser                   |
| `flutter run -d linux`         | Run as Linux desktop app                |
| `flutter devices`              | List all available devices              |
| `flutter build apk`            | Build release APK                       |
| `flutter build apk --debug`    | Build debug APK                         |
| `flutter clean`                | Clear build cache (useful for errors)   |

---

## Troubleshooting

- **`flutter: command not found`** → Make sure `~/flutter/bin` is in your PATH (see Step 1).
- **Gradle build fails** → Run `flutter clean` then `flutter pub get` and retry.
- **Device not detected** → Check `adb devices`, re-plug USB, and re-authorize on phone.
- **`flutter doctor` shows issues** → Follow the doctor's suggestions to resolve each item.
