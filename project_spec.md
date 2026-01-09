# 📱 Project Specification: Pokemon Emotion Diary (MadCamp Week 1)

> **Context:** This file defines the technical specifications for the "Pokemon Emotion Diary" app. 
> **Goal:** All AI code generation/assistance must strictly follow these rules to ensure consistency between team members.
> **Role Assignment:**User is responsible for **Part B: Data Modeling, Local DB (sqflite), and API Service**.

---

## 1. Project Overview
- **Goal:** A gamified diary app that analyzes the user's daily emotion and rewards them with a Pokemon card collection.
- **Platform:** Flutter (Android/iOS)
- **Duration:** MadCamp Week 1 (Speed & Stability are priorities)
- **Core Loop:** Write Diary → Analyze Sentiment → Gacha (Pokemon Draft) → Save to DB → Update Pokedex.

---

## 2. Tech Stack & Constraints
- **Language:** Dart (Flutter)
- **State Management:** `Provider` (Simple & Effective for Week 1)
- **Local Database:** `sqflite` (No Backend Server)
- **Network:** `http` package
- **Image Caching:** `cached_network_image`
- **External API:** [PokeAPI](https://pokeapi.co/) (Gen 1: #1 ~ #151 only)
- **AI/Logic:** Dart-based Sentiment Analysis Library

---

## 3. Architecture & Folder Structure
Follow the strict `lib/` directory structure:
```text
assets/
├── data/
│   └── pokemon_data.csv  # Pre-generated Pokemon metadata
└── images/
    ├── logo/             # App logos
    └── ...

lib/
├── main.dart             # App Root & Theme configuration
├── home_screen.dart      # Main Layout with Header & BottomNavigationBar
├── models/               # [Part B] Data Models
│   ├── diary_model.dart  # Data structure for user's diary entries
│   └── pokemon_model.dart# Data structure for Pokemon metadata
├── services/             # [Part B] Services & Business Logic
│   ├── db_helper.dart    # SQLite Database management
│   ├── gacha_logic.dart  # Random Pokemon selection logic
│   ├── api_service.dart  # Local CSV parsing & Image URL management
│   └── sentiment_service.dart # [Part C] Language detection & Sentiment analysis
├── screens/              # [Part A] Tab Views
│   ├── tab1_draft.dart   # Diary input & Gacha animation logic
│   ├── tab2_diary.dart   # List of historical diary entries
│   └── tab3_pokedex.dart # Grid view for Pokemon collection
└── widgets/              # Reusable UI Components
    ├── pokemon_image.dart# Handling static/gif images & silhouettes
    └── emotion_badge.dart# Visual indicator for analyzed emotions
```

---

## 4. Database Schema (SQLite) - [Part B Core]
Since there is no backend, `sqflite` manages user-generated data, while a pre-baked CSV handles the Pokemon metadata.

### Table: `diaries`
| Column Name  | Type                      | Description                                   |
| :----------- | :------------------------ | :-------------------------------------------- |
| `id`         | `INTEGER PK AUTOINCREMENT` | Unique ID for each entry                      |
| `date`       | `TEXT`                    | ISO-8601 String (YYYY-MM-DD)                  |
| `content`    | `TEXT`                    | Raw text content of the user's diary          |
| `sentiment`  | `TEXT`                    | Result of analysis (e.g., 'joy', 'sad', 'angry')|
| `pokemon_id` | `INTEGER`                 | ID of the drafted Pokemon (FK to CSV ID)      |

> **⚠️ Implementation Note:** The `diaries` table will perform a logical JOIN with the local Pokemon metadata using `pokemon_id`.

### 4.1. Input Validation Rules
- **Data Type:** Use `TEXT` for `content` (flexible length in SQLite).
- **Min Length:** 10 characters (Korean/English combined) to ensure accurate sentiment analysis.
- **Max Length:** 1,000 characters (UI stability).
- **Handling:** UI should show a character counter and prevent "Gacha" if the text is too short.

---

## 5. External Data & Image Strategy
To ensure high performance and rich UI, Pokemon metadata is pre-baked into a CSV, and images are strategicially sourced from PokeAPI's various repositories.

### 5.1. Local Asset: `pokemon_data.csv`
- **Location:** `assets/data/pokemon_data.csv`
- **Schema:**
  - `id`: Index (1~151)
  - `english_name` / `korean_name`: Dual-language names
  - `dex_entry_english` / `dex_entry_korean`: Description texts
  - `type_1`, `type_2`: Pokemon types
  - `is_legendary` / `is_mythical`: Boolean (0 or 1)
  - `height` / `weight`: Physical traits
  - `sprite_url`: Static High-quality (Home version)
  - `gif_url`: Animated (Showdown version)
  - `icon_url`: Small icon (Gen VIII style)

### 5.2. Image Asset Mapping & Usage
Each image type is assigned to a specific UI component to balance visual appeal and performance:

1. **High-Quality Detail Image (Home Art):**
   - **Usage:** Diary Detail View, Gacha Result Screen
   - **URL:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{id}.png`
   
2. **Animated Grid Image (Showdown GIF):**
   - **Usage:** Pokedex Grid View (Tab 3)
   - **URL:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/{id}.gif`

3. **Small List Icon (Gen VIII Icons):**
   - **Usage:** Diary History List (Tab 2)
   - **URL:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/{id}.png`
   
---

## 6. Business Logic Rules (Localization & Analysis)

### 6.1. Smart Language Handling (Korean/English Mixed)
- **Detection Logic:** Use a Regular Expression (Regex) to check for the presence of Korean characters (`[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]`).
- **Processing Flow:**
  - **Case A: Pure English** -> Pass directly to `SentimentService`. (Faster, saves API calls)
  - **Case B: Korean only OR Mixed (KO+EN)** -> Pass the entire string to `google_translator`.
    - *Example:* "오늘 정말 happy했어" -> (Translator) -> "I was really happy today."
- **Reasoning:** Google Translator handles mixed-language context naturally, providing a more coherent English sentence for the sentiment analyzer than separate processing.
- **Persistence:** Regardless of the analysis path, the **original input string** (the mixed text) must be stored in the `content` column of the `diaries` table.

### 6.2. Sentiment -> Pokemon Type Mapping
The system maps the English-analyzed sentiment result to specific Pokemon types:
- Joy / Happy: Electric, Flying, Fairy (e.g., Pikachu, Dragonite)
- Sad / Depressed: Water, Ghost, Ice (e.g., Squirtle, Gengar)
- Angry / Stress: Fire, Fighting, Dragon (e.g., Charmander, Machamp)
- Calm / Normal: Grass, Normal, Bug (e.g., Bulbasaur, Snorlax)

### 6.3. Gacha (Drafting) System Flow
1. **Language Check:** Detect if the input is English or Korean.
2. **Preprocessing:** - [Korean] Translate to English.
   - [English] Skip translation.
3. **Analyze:** Run sentiment analysis on the English text (translated or raw).
4. **Filter:** Filter the local `pokemon_data.csv` list by the matched types from 6.2.
5. **Draft:** Randomly select one `pokemon_id` from the filtered subset.
6. **Persist:** Save the **Original Raw Content** (whether it was Korean or English) and the selected `pokemon_id` to the `diaries` table.

---

## 7. UI/UX Guidelines (Updated)

### Tab 1: Diary Write & Gacha
- **Input:** Clean Korean/English text field.
- **Gacha:** Upon submission, show a Pokeball animation.
- **Result:** Reveal the **Home Art (Static)** of the drafted Pokemon with its Korean name and type.

### Tab 2: Diary History
- **List Item:** Each card shows the **Gen VIII Icon** on the left, followed by the Date and a snippet of the diary.
- **Efficiency:** Icons are very small, ensuring smooth scrolling in the `ListView`.

### Tab 3: Pokedex (Gallery)
- **Grid:** 3-column layout. 
- **Display:** Each cell shows the **Showdown GIF** (Animated) to give the Pokedex a dynamic feel.
- **Interaction:** - **Locked:** Black silhouette (using `ColorFiltered`) with the Pokemon's Index number.
  - **Unlocked:** Full-color GIF. 
  - **Click:** Navigate to a Detail Page showing the **Home Art**, Description, and Physical stats.
  
---

## 8. Coding Conventions
- **Style:** Strictly follow [Effective Dart](https://dart.dev/guides/language/effective-dart) (camelCase for members, PascalCase for types).
- **Asynchronous:** Always use `async/await` syntax. Avoid `.then()` callbacks.
- **Sound Null Safety:** Required. Use `required` for all non-nullable model parameters.
- **Documentation:** Provide meaningful comments for complex logic in `db_helper.dart` and `api_service.dart`.

### 8.1. Debugging & Maintenance Utilities
- **Clear Data:** Provide a `clearDatabase()` method in `db_helper.dart` for testing.
- **Mock Seeding:** Provide a `seedMockData()` method to populate `diaries` for UI testing.
- **Raw Query Support:** Allow executing raw SQL strings for quick debugging during the development phase.

---
