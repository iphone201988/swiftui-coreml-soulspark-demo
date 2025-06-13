# 🧠 SoulSpark – Secure Journal App

SoulSpark is a journaling app built using **Swift**, **SwiftUI**, and **Core Data**, with end-to-end encryption powered by **CryptoKit**. It securely stores user-generated journal entries, including mood metadata and encrypted content.

---

## 📌 Table of Contents

* [Project Overview](#project-overview)
* [Technical Decisions](#technical-decisions)
* [Security & Encryption](#security--encryption)
* [Core Data Architecture](#core-data-architecture)
* [Core ML Integration](#core-ml-integration)
* [Optimizations](#optimizations)
* [Trade-Offs](#trade-offs)
* [Future Improvements](#future-improvements)
* [Testing Notes](#testing-notes)
* [Contribution & License](#contribution--license)

---

## 🧱 Project Overview

* Store encrypted journal content using Core Data.
* Support moods, timestamps, and UUIDs per entry.
* Use **AES-GCM encryption** for secure storage.
* Core Data backed by `NSPersistentContainer` (via `PersistenceController`).

---

## 💡 Technical Decisions

### 1. **PersistenceController vs CoreDataStack**

We chose **`PersistenceController`** (Apple's recommended approach) over a custom `CoreDataStack` to:

* Align with SwiftUI’s `@Environment(\.managedObjectContext)` pattern.
* Simplify context access and avoid singleton abuse.
* Enable `inMemory` stores for testing and previews.

### 2. **Binary Data for Encrypted Content**

Encrypted journal content is stored as **Binary Data** in Core Data (`NSData`) to:

* Prevent issues with non-printable or special characters in encrypted strings.
* Enable large entry support and optional external storage.

### 3. **External Storage Enabled**

The Core Data model has **"Allows External Storage"** enabled for the `journalContent` attribute:

* Allows large binary blobs to be stored as files rather than in SQLite blobs.
* Optimizes storage performance and reduces memory pressure.

---

## 🔐 Security & Encryption

### 🔑 Key Generation & Management

* **CryptoKit** is used for symmetric encryption via `AES.GCM`.
* A 256-bit key is generated once and stored securely using **Keychain**.
* Key is retrieved from Keychain for each encrypt/decrypt operation.

### 🧰 Keychain Helper Utility

* Key is tagged (`com.yourapp.encryptionkey`) for safe lookup.
* Automatically generates and persists a key if not found.

### ✨ Encryption/Decryption Flow

* Before saving, `journalContent` is encrypted with AES-GCM and stored as binary.
* During fetch, binary is decrypted on-the-fly using the saved key.

---

## 📂 Core Data Architecture

### Model: `JournalEntry`

* `id: UUID`
* `timestamp: Date`
* `mood: String`
* `journalContent: Binary Data` (Encrypted content)

### Storage

* Uses default `NSPersistentContainer`.
* Autosaves on background or context changes.
* Handles multiple entries and encrypted fetches.

---

## 🧠 Core ML Integration

### 📌 Purpose

SoulSpark uses **Core ML** to analyze journal entries and intelligently suggest or classify moods based on the encrypted content, offering a smarter and more personalized journaling experience.

### 🤖 Model Training

* Trained using **Create ML** on a curated dataset of emotional text entries.
* Dataset included labeled moods like:

  * `happy`
  * `sad`
  * `angry`
  * `relaxed`
* The model used is a **Text Classifier** trained on user-written sentences to infer emotional tone.

### ⚙️ Implementation Details

* The `.mlmodel` file is embedded in the app bundle and auto-converted into a native Swift class.
* On entry creation or viewing:

  * Encrypted journal content is **decrypted locally**.
  * The decrypted text is passed to the model for prediction.
* Resulting mood is either:

  * Displayed as a suggestion, or
  * Auto-filled if the user hasn't selected a mood.

```swift
let prediction = try? moodModel.prediction(text: journalText)
entry.mood = prediction?.label ?? "unknown"
```

### 🔒 Privacy & Security

* All predictions are made **on-device**, using Apple’s Core ML runtime.
* No journal text leaves the device—ensuring full **user data privacy**.
* The integration aligns with the app’s zero-knowledge design goals.

---

## 🚀 Optimizations

* Binary Data is marked for **External Storage** (optional).
* `@MainActor` used for preview context to avoid threading bugs in SwiftUI Previews.
* Only the necessary data is decrypted when displayed, reducing runtime costs.
* Persistent store merges parent changes automatically.

---

## ⚖️ Trade-Offs

| Decision                               | Trade-off                                                                 |
| -------------------------------------- | ------------------------------------------------------------------------- |
| Use AES-GCM encryption                 | Slightly larger payloads, more complexity                                 |
| Store as Binary instead of String      | Harder to debug, but safer and more accurate                              |
| Keychain for key persistence           | Slight complexity, but provides security                                  |
| `PersistenceController` over Singleton | Cleaner SwiftUI integration, but less flexible for UIKit apps             |
| External Storage for Binary Data       | Better for performance, but adds complexity to migration if changed later |

---

## 📊 Future Improvements

* Add iCloud sync with encrypted Core Data stores.
* Add biometric authentication (Face ID/Touch ID) before decryption.
* Build custom migration logic for encrypted stores across versions.
* UI warning when encryption/decryption fails.

---

## 🧪 Testing Notes

* Use `PersistenceController.preview` for generating mock data.
* Journal entries can be verified via decryption debug logs.
* Ensure Keychain is not cleared between runs in simulator resets.

---

## 🤝 Contribution & License

Feel free to fork, adapt, or build upon this secure journaling framework.
🔐 Security is a shared responsibility. Use wisely.
