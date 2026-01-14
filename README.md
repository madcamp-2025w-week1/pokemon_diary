# Pokemon Emotion Diary 📔⚡

A gamified diary application built with Flutter that analyzes your daily emotions using AI and rewards you with Pokemon cards!

Record your day, understand your feelings, and complete your Pokedex.

## ✨ Features

- **📝 Smart Diary:** Write your daily thoughts in English or Korean.
- **🧠 AI Sentiment Analysis:** The app uses the Hugging Face API (RoBERTa model) to analyze your emotions (Joy, Sadness, Anger, Calm).
- **🎁 Pokemon Gacha System:** Get rewarded with a Pokemon draft based on your emotion!
    - Happy? You might attract Electric, Flying, or Fairy types!
    - Sad? Water, Ghost, or Ice types might appear.
    - Angry? Fire, Fighting, or Dragon types are drawn to your energy.
    - Calm? Grass, Normal, or Bug types will appear.
- **📖 Pokedex:** Collect all 151 Gen 1 Pokemon. View detailed stats and retro sprites.
- **🆔 Trainer Card:** Customize your profile with badges and personal stats.
- **🎨 Retro Aesthetic:** Pixel art style with fluid modern animations using Lottie.

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code or Android Studio).

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/your-username/pokemon_diary.git
    cd pokemon_diary
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **🔑 API Key Configuration (Crucial Step)**
    To use the AI Sentiment Analysis features, you need a Hugging Face Access Token.
    
    1.  Go to [Hugging Face Settings -> Tokens](https://huggingface.co/settings/tokens).
    2.  Create a new Access Token (Type: Read).
    3.  Create a new file named `api_keys.dart` inside the `lib/` directory.
    4.  Add the following code to `lib/api_keys.dart`:

    ```dart
    // lib/api_keys.dart
    const String huggingFaceAPIKey = "YOUR_HUGGING_FACE_ACCESS_TOKEN_HERE";
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

## 📱 How to Use

1.  **Write:** Go to the "Draft" tab and write about your day.
2.  **Analyze:** Submit your entry. The AI will analyze your sentiment.
3.  **Collect:** Watch the Pokeball animation and reveal your new Pokemon partner!
4.  **View:** Check your collection in the "Pokedex" tab or view past entries in the "Diary" tab.

## 📂 Project Structure

```
lib/
├── main.dart             # App Entry Point & Provider Setup
├── home_screen.dart      # Main Navigation Controller
├── api_keys.dart         # (You must create this) API Keys
├── models/               # Data Models (Pokemon, Diary, Badge)
├── providers/            # State Management (DiaryProvider, PokedexProvider, etc.)
├── screens/              # UI Screens (Diary, Pokedex, Popups)
├── services/             # Logic (API, Database, Sentiment Analysis)
└── utils/                # Helpers (Date formatting, UI Themes)
```

## 📦 Build & Deploy

To build the APK for Android:

```bash
flutter build apk --release
```

The output file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## 🛠 Tech Stack

-   **Framework:** Flutter (Dart)
-   **State Management:** Provider
-   **Local Database:** sqflite
-   **AI Model:** RoBERTa (via Hugging Face API)
-   **Animations:** Lottie
-   **Data Source:** PokeAPI (Sprites & Data)

## 📄 License

This project is for educational purposes (MadCamp).

## 🙏 Acknowledgments

-   **PokeAPI** for the comprehensive Pokemon data and sprites.
-   **Hugging Face** for the emotion classification models.
-   **Galmuri & DungGeunMo** for the beautiful pixel fonts.