<div align="center">
  <img src="assets/images/philosopher_default.png" width="120" alt="Logo" />
  <h1>沉思室 (Philosophy Sayings)</h1>
  <p>
    <a href="README_zh-CN.md">🇨🇳 中文文档 (Chinese)</a> | 🇬🇧 English Documentation
  </p>
</div>

An immersive, aesthetically pleasing Flutter application that delivers daily philosophical quotes with deep, AI-powered explanations.

## 🌟 Features

### Core Experience
*   **Daily Wisdom**: Display curated quotes from great philosophers (e.g., Nietzsche, Camus, Heidegger).
*   **Deep Explanation (哲言妄解)**: Poetic and insightful breakdowns of the meaning behind each quote.
*   **Existentialism Bias**: Optimized prompts to explore themes of modern nihilism, focus on existentialists and classical thinkers.
*   **Dynamic Assets System**: Smart mapping of philosopher names to local asset images with random high-quality variations.
*   **Multi-Model Support**: Integrated with leading Chinese LLMs including DeepSeek, Qwen (Tongyi Qianwen), MiniMax, and Moonshot (Kimi).
*   **Offline First / Degradation**: Graceful fallback to rich mock data ("SAMPLE / 示例" indicator) when offline or when API tokens are unavailable.
*   **Experience Mode Rate Limiter**: Elegant, non-intrusive daily quota (max 20/day) for built-in API keys to prevent abuse while maintaining immersion.

### The Philosopher's Chamber (哲学家的密室)
*   **Immersive Chat**: Step into a private "chamber" (dark aesthetic UI) to converse directly with the philosopher who authored the quote.
*   **Persona Engine**: Each philosopher has a distinct personality driven by LangChain.dart (`lib/config/prompts.dart`).
*   **Contextual Opening**: The philosopher initiates the conversation based on the specific quote you are viewing.
*   **Session Persistence**: Chat history is preserved per quote during the app session (State Lifting).

### Utilities & UX
*   **Echoes of the Soul (收藏夹)**: A dedicated space to revisit your collected wisdom, featuring a masonry grid layout and SQLite persistence.
*   **Share as Image**: Convert your current wisdom into a beautiful image card for social sharing (`RepaintBoundary`).
*   **Seamless Dark Splash Screen**: Immersive loading experience without white-flashes, utilizing `flutter_native_splash`.
*   **Adaptive Layouts**: Seamlessly switches between macOS Desktop App and standard cards (Mobile/iOS/Android).

## 🏗 Architecture (Semantic Layering)

The codebase is organized following a robust semantic separation of concerns:
*   `lib/config/`: Configuration files and decoupled AI Prompts (`prompts.dart`).
*   `lib/models/`: Pure Dart data structures (`quote.dart`, `llm_config.dart`).
*   `lib/services/`: Core business logic decoupled from the UI:
    *   `llm_service.dart`: LangChain integration and LLM pipelines.
    *   `database_helper.dart` & `favorites_service.dart`: SQLite Local Storage.
    *   `preference_service.dart`: SharedPreferences for settings.
*   `lib/ui/pages/`: Main screens (`home_page.dart`, `settings_page.dart`, `philosophers_chamber_page.dart`).
*   `lib/ui/widgets/`: Reusable UI components (`quote_card.dart`).
*   `lib/utils/`: Pure helper functions (`json_utils.dart` for robust AST-level JSON JSON repair).

*(Note: Key sections of the code, especially LangChain logic and State Management, contain detailed Chinese educational comments to aid developers new to these frameworks.)*

## 🚀 Getting Started

1.  **Prerequisites**: Flutter SDK installed.
2.  **Run the App**:
    ```bash
    flutter pub get
    flutter run
    ```
3.  **API Key Setup (Required for real AI data)**:
    By default, the Experience Mode requires an API key in `llm_service.dart`. 
    Alternatively:
    *   Go to **Settings** (Gear Icon on Home Page).
    *   Switch to **Speed Mode**.
### 🎁 Download for Mac
1. Download **`PhilosophySayings.dmg`** from the [GitHub Releases](https://github.com/Sparkle6979/PhilosophySayings/releases).
2. Double-click and drag the App to your Applications folder.
3. Enjoy an immersive flow of daily wisdom with built-in experience limits.
*Created with ❤️ by Antigravity & Sparkle79*
