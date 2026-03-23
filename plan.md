# 📔 Project: The Persistent Vault (Personal English Diary & Warehouse)

## 🌟 Mission Statement
A minimalist, high-end digital notebook designed for a language learner who values **persistence** over automation. This is not a flashcard app; it is a **private sanctuary** for words, thoughts, and career-oriented English growth. No complex AI tokens, no bloat—just pure, aesthetic functionality.

---

## 🎨 UI/UX Design Language (The "Aesthetic" Part)
* **Theme:** "Modern Moleskine". Soft dark mode (Charcoal #121212) and "Paper White" light mode (#F5F5F7).
* **Typography:** Elegant Serif for headings (like *Playfair Display*) and clean Sans-Serif for body text (*Inter* or *Roboto*).
* **Feel:** Smooth micro-animations, card-based layout with subtle shadows, and plenty of white space.
* **Core Principle:** "One screen, one focus." No cluttered menus.

---

## 🛠 Technical Stack
* **Framework:** Flutter (Recommended for high-end UI) or React Native.
* **Database:** Local-first (SQLite or Hive). No cloud accounts required.
* **External Integration:** [Free Dictionary API](https://dictionaryapi.dev/) (No token/auth needed).

---

## 🚀 Core Features & Logic

### 1. The Word Warehouse (Manual Data Entry)
A digital vault to store "captured" words.
* **Inputs:** Word, Meaning (Manual), My Sentence (Personal context), and Tags (e.g., #Business, #Daily).
* **Auto-Enrichment:** When a word is saved, call the `Free Dictionary API` to fetch:
    * Audio pronunciation (if available).
    * Synonyms.
    * Phonetic spelling.
* **Action:** A long-press on a word plays the audio.

### 2. The English Journal (Daily Diary)
A dedicated space to write 3-5 sentences about the day in English.
* **Word Integration:** While writing, if the user types a word that exists in their "Warehouse," the word should be **highlighted** or underlined.
* **Character Count:** Small, non-intrusive count to encourage writing.
* **Archive:** Calendar view to see past entries.

### 3. The Toolbox (Zero-AI Utilities)
* **Search:** A high-speed global search for any word or journal entry.
* **Flash-Flip:** A simple "Random Word" card on the home screen that shows a word from the warehouse to refresh memory.
* **Export:** Ability to export the warehouse as a PDF or CSV (for safety).

---

## 📊 Database Schema (Technical Precision)

**Table: Words**
* `id` (Primary Key)
* `term` (String)
* `meaning` (String)
* `example_sentence` (Text)
* `synonyms` (String/Array)
* `audio_url` (String)
* `created_at` (Timestamp)
* `category_tag` (String)

**Table: Journal**
* `id` (Primary Key)
* `entry_text` (Text)
* `mood_emoji` (String)
* `created_at` (Timestamp)

---

## 📝 The AI "Execution" Prompt
*(Copy-paste this to the AI after giving the .md file)*

> "Based on the attached specification, please build the first iteration of **The Persistent Vault**. 
> 1. Start by creating the **Home Screen** which features a 'Word of the Day' card from the database and a quick 'Add' button.
> 2. Ensure the UI uses the **Modern Moleskine** aesthetic described (Serif fonts, smooth shadows).
> 3. Implement the **Free Dictionary API** integration so that when I add a word, it fetches the audio and synonyms automatically.
> 4. Use **Local Storage** so I don't need an account. 
> Please provide the code for the main structure first."

---
