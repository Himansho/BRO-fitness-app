# Aura Fitness & Nutrition Journal 🛡️

A 100% private, local-first, encrypted fitness and nutrition tracker. All your logs, stats, and progress photos stay strictly on your device – secured with bank-grade local encryption.

---

## 📦 Mobile App Downloads

Get the latest native mobile builds directly from our automated build pipeline:

* 🤖 **[Download Android APK (Direct Link)](https://github.com/Himansho/BRO-fitness-app/releases/download/latest/AuraFitness-Android.apk)**
* 🍎 **[Download iOS Xcode Project (Direct Link)](https://github.com/Himansho/BRO-fitness-app/releases/download/latest/AuraFitness-iOS-Xcode-Project.zip)**

*Note: The downloads will become active as soon as the latest GitHub Actions workflow run completes and generates the release files.*

---

## ✨ Features

* **🛡️ End-to-End Local Encryption:** All data (meals, workouts, progress photos) is encrypted using **AES-GCM (256-bit)** using a key derived from your 4-digit PIN via **PBKDF2** (100,000 iterations, SHA-256).
* **🍳 Detailed Food Logging:** Preloaded offline database containing Indian and international dishes. Calculates calories and macros dynamically based on portion sizes.
* **🏋️ Set-by-Set Workout Logging:** Track weights, sets, and reps with automatic previous-session loading for progressive overload analysis.
* **📸 Secure Photo Progress Journal:** Canvas-based client-side photo compression. Side-by-side comparison mode with body transformation stats.
* **⏰ Smart Reminders:** Configurable offline reminders that check system time and push alerts.
* **📊 SVG Progress Charts:** Custom-designed, premium trend lines mapping weight, steps, and calories.
* **📥 100% Offline Backups:** Export your raw encrypted database to a local JSON file, and restore it on any device.

---

## 🚀 Running Locally

### 1. Install dependencies
```bash
npm install
```

### 2. Launch Local Dev Server
```bash
npm run dev
```
Open the provided local URL (typically `http://localhost:5173`) in your browser.

---

## 🛠️ Automated Mobile Build Architecture

This repository uses **Capacitor** to wrap the web assets into native project directories and **GitHub Actions** workflows to automatically compile the final mobile apps:
1. Every push to the `main` branch triggers two parallel build agents (Ubuntu and macOS).
2. The Ubuntu runner builds the project and uses Gradle to compile the **Android debug APK**.
3. The macOS runner builds the project, configures the Xcode workspace, and packages the **iOS project**.
4. A third release agent compiles these artifacts and publishes them to the **`latest`** release tag for one-click downloading.
