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

### 📓 English Journal
- Write 3–5 sentences about your day in English
- Words from your warehouse are **automatically highlighted** as you type
- Mood emoji selector (😊 🔥 💪 ✨ ...)
- Character count to encourage writing
- **Calendar archive** to revisit past entries

### 🏠 Flash-Flip Card
- A random "Word of the Day" on the home screen with a **3D flip animation**
- Tap to reveal meaning, synonyms, and example sentence
- Shuffle for a new word anytime

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

---

## 📁 Project Structure

```
lib/
├── main.dart                        # Entry point, providers, navigation shell
├── db/
│   └── database_helper.dart         # SQLite CRUD for words & journal
├── models/
│   ├── word.dart
│   └── journal_entry.dart
├── services/
│   └── dictionary_service.dart      # Free Dictionary API client
├── providers/
│   ├── word_provider.dart
│   ├── journal_provider.dart
│   └── theme_provider.dart
├── theme/
│   └── app_theme.dart               # Dark & light theme definitions
├── screens/
│   ├── home_screen.dart             # Flash-flip card, stats, quick actions
│   ├── warehouse_screen.dart        # Word list, search, tags, audio
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
