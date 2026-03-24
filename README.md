# 📔 The Persistent Vault

> *"Stay persistent, grow relentless."*

A minimalist, premium **personal English diary & word warehouse** built with Flutter. Designed for language learners who value **persistence over automation** — no flashcard gimmicks, no cloud accounts, just a private sanctuary for words, thoughts, and growth.

---

## ✨ Features

### 📦 Word Warehouse
- Manually capture words with meaning, personal example sentence, and tags
- **Auto-enrichment** via [Free Dictionary API](https://dictionaryapi.dev/) — fetches pronunciation audio, phonetic spelling, and synonyms
- 🔊 Long-press any word to hear its pronunciation
- Filter by tags (#Business, #Daily, #Academic...)
- Swipe to delete

### 🌱🌿🌳 Spaced Repetition (SRS)
- **3-tier mastery system**: Seed → Sprout → Oak
- Flash-Flip card **prioritizes unlearned words** (75% weight on Seed/Sprout)
- Tap **"Knew it!"** to promote a word's mastery level
- Mastery badges displayed on every word card

### 📓 English Journal
- Write 3–5 sentences about your day in English
- Words from your warehouse are **automatically highlighted** as you type
- Mood emoji selector (😊 🔥 💪 ✨ ...)
- Character count to encourage writing
- **Calendar archive** to revisit past entries

### 🔥 Streak System (Persistence Engine)
- Dynamic **flame icon** on the home screen tracks your daily streak
- Golden glow when active, grey when inactive
- Streak resets if you miss a 24-hour window
- 🎊 **Confetti celebration** at milestones: 7, 30, 100, 365 days

### 🔔 Smart Notifications
- ☀️ **Morning Challenge** (09:00) — A word to start your day
- 🌙 **Evening Reflection** (21:00) — Reminder to write your journal
- Toggleable from the settings drawer

### 🏠 Flash-Flip Card
- **SRS-weighted "Word of the Day"** with a **3D flip animation**
- Tap to reveal meaning, synonyms, and example sentence
- "Knew it" / "Didn't know" buttons for mastery progression

### 🔍 Global Search
- Search across **all words and journal entries** simultaneously
- Results grouped by type

### 📤 Export
- **CSV export** of your entire word warehouse
- **PDF export** with styled layout via the drawer menu

### 🌗 Dark / Light Mode
- **Modern Moleskine** aesthetic
- Dark: Charcoal `#121212` with warm golden accents
- Light: Paper White `#F5F5F7` with subtle shadows
- Persisted between sessions

### 📳 Haptic Feedback
- Tactile feedback on word save, audio playback, and form submission
- Premium feel on every interaction

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | **Flutter** (Dart) |
| State Management | **Provider** |
| Local Database | **SQLite** (sqflite) |
| API | [Free Dictionary API](https://dictionaryapi.dev/) — no auth needed |
| Audio | audioplayers |
| Fonts | Google Fonts (Playfair Display + Inter) |
| Export | csv + pdf + printing |
| Calendar | table_calendar |
| Notifications | flutter_local_notifications + timezone |
| Animations | confetti |
| Haptics | vibration |

---

## 📁 Project Structure

```
lib/
├── main.dart                        # Entry point, providers, navigation shell
├── db/
│   └── database_helper.dart         # SQLite CRUD + DB migration (v2)
├── models/
│   ├── word.dart                    # Word model + MasteryLevel enum
│   └── journal_entry.dart
├── services/
│   ├── dictionary_service.dart      # Free Dictionary API client
│   └── notification_service.dart    # Morning/evening smart reminders
├── providers/
│   ├── word_provider.dart           # SRS mastery + weighted Flash-Flip
│   ├── journal_provider.dart
│   ├── theme_provider.dart
│   └── streak_provider.dart         # Streak tracking + milestones
├── theme/
│   └── app_theme.dart               # Dark & light theme definitions
├── screens/
│   ├── home_screen.dart             # Flame, mastery bar, confetti, flip card
│   ├── warehouse_screen.dart        # Word list, search, tags, mastery badges
│   ├── add_word_screen.dart         # Add word form + API enrichment
│   ├── journal_screen.dart          # Editor + calendar archive
│   └── search_screen.dart           # Global search
└── utils/
    └── export_utils.dart            # CSV & PDF export
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+)

### Run
```bash
git clone https://github.com/Gimli361/ThePeristentVault.git
cd The_Persistent_Vault
flutter pub get
flutter run
```

---

## 📸 Screenshots

<!-- Add your screenshots here -->
<!-- ![Home Screen](screenshots/home.png) -->
<!-- ![Word Warehouse](screenshots/warehouse.png) -->
<!-- ![Journal](screenshots/journal.png) -->

---

## 📄 License

This project is licensed under the MIT License.

---

<p align="center">
  Built with ❤️ and <b>persistence</b>
</p>
