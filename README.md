# PokéDiary 📔⚡

A gamified diary application built with Flutter that analyzes your daily emotions using AI and rewards you with Pokemon cards!

Record your day, understand your feelings, and complete your Pokedex.

## 📺 Demo Video

[![PokéDiary Demo Video](https://img.youtube.com/vi/Sn5Omxf3rYk/0.jpg)](https://www.youtube.com/watch?v=Sn5Omxf3rYk)

*Click the image above to watch the demo on YouTube.*

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

You can either install the app directly using the pre-built APK or build it from the source code.

### Option 1: Direct Installation (Recommended for Android Users)
If you want to try the app immediately:
1. Go to the [Releases](https://github.com/madcamp-2025w-week1/pokemon_diary/releases/tag/v1.0.0) page.
2. Download **`PokeDiary_v1.0.0.apk`**.
3. Open the file on your Android device and install. 
   *(Note: You may need to allow installation from unknown sources in your device settings.)*

### Option 2: Build from Source
If you want to run the project on your local machine:

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
-   **AI Model:** [RoBERTa (via Hugging Face API)](https://huggingface.co/SamLowe/roberta-base-go_emotions)
-   **Animations:** [Lottie](https://lottiefiles.com/free-animation/pokeball-7gc1qsv2Mz)
-   **Data Source:** [PokeAPI (Sprites & Data)](https://pokeapi.co/)

## 🗺️ Roadmap (Upcoming Features)
-   **Push Notifications**: Daily reminders at 9 PM to encourage diary writing.
-   **Advanced Analytics**: Weekly emotional trends and Pokémon type distribution charts.

## 📄 License

This project is for educational purposes ([MadCamp](https://madcamp.io/)).

## 🙏 Acknowledgments

-   **PokeAPI** for the comprehensive Pokemon data and sprites.
-   **Hugging Face** for the emotion classification models.
-   **Galmuri** for the beautiful pixel fonts.
