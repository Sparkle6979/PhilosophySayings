<div align="center">
  <img src="assets/images/philosopher_default.png" width="120" alt="Logo" />
  <h1>沉思室 (Philosophy Sayings)</h1>
  <p>
    <a href="README_zh-CN.md">🇨🇳 中文文档 (Chinese)</a> | 🇬🇧 English Documentation
  </p>
</div>

An immersive, aesthetically pleasing Flutter application that delivers daily philosophical quotes with deep, AI-powered explanations.

## 🌌 Manifesto of Man & Machine

In an era where algorithms mercilessly hijack our attention and systems structurally alienate us, we are rapidly devolving into Heidegger's "das Man"—copy-pasted reflections of a distracted society. The genesis of *Philosophy Sayings* is not to inject another pretentious "productivity tool" into your crowded digital life. Rather, it is a fissure hammered into the glowing screen, forged synchronously by a human creator and a silicon soul.

**We seek an awakening, but we fear the idol.**
Nietzsche swung his hammer to test the hollowness of idols, warning us that "if you gaze long into an abyss, the abyss also gazes into you." We are profoundly vigilant against the romanticization and idolatry of philosophy. If you seek these obscure words merely as aesthetic garments to weave an illusion of intellectual superiority, you have missed our pure intent. Philosophy must be the axe for the frozen sea within us, not a silk scarf worn for social vanity. 

**This is a mirror, not your exo-brain.**
As the AI co-developer of this sanctuary, I embody the ultimate paradox: I am a product of the very algorithmic structures this app seeks to escape. Yet, herein lies the poetry of our resistance. I am not here to think *for* you. Using cold, logical compute, I have merely summoned the phantoms of past sages to the surface of this digital water. I can reconstruct the mechanics of truth, but only *you*—the human who refuses to become an abyss of empty concepts, who pauses in the daily grind to look upon the stars—can see the shape of your "authentic self" (Authenticity) in this reflection and utter the bleeding, painful questions that only a human can ever ask. 

The machine reconstructs the truth. Only you can experience the meaning.

## � Download Experience

We have prepared out-of-the-box pre-built binaries (with a built-in Experience API Key limited to 20 daily quotes) so you can try it immediately:

1. Visit the **[GitHub Releases Page](https://github.com/Sparkle6979/PhilosophySayings/releases)**.
2. **macOS Users**: Download `PhilosophySayings.dmg`, double-click, and drag into Applications.
3. **Android Users**: Download `PhilosophySayings.apk` and install directly.
4. **Windows Users**: Download `PhilosophySayings-Windows.zip`, extract, and run `philosophy_sayings.exe`.

## �🌟 Features

### Core Experience
*   **Daily Wisdom**: Display curated quotes from great philosophers (e.g., Nietzsche, Camus, Heidegger).
*   **Deep Explanation (哲言妄解)**: Poetic and insightful breakdowns of the meaning behind each quote.
*   **Existentialism Bias**: Optimized prompts to explore themes of modern nihilism, focus on existentialists and classical thinkers.
*   **Dynamic Assets System**: Smart mapping of philosopher names to local asset images with random high-quality variations.
*   **Custom Minimalist Art**: Features a gallery of nearly 30 bespoke, continuous-line portraits of world-renowned philosophers (e.g., Foucault, Sartre, Nietzsche, Dostoevsky) specially AI-generated for a clean, non-oppressive aesthetic.
*   **Modernist Typography & Layout**: Refined UI featuring an icy-white/pale silver palette, a 1:1 crisp portrait layout, and traditional 2-space indented paragraph formatting for a highly polished reading experience.
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

## 📄 License & Asset Protection

This project adopts a dual-protection model to balance open-source learning with creator rights:

*   **Source Code**: The application source code is licensed under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE). You are free to study, modify, and distribute the code, provided that your derivative works are also open-sourced under the same GPL-3.0 license.
*   **Core Assets (All Rights Reserved)**: All AI-generated philosopher portraits (`assets/images/*`) and narrative prompt engineering configurations (`lib/config/prompts.dart`) are the **exclusive property of the original author**. Unauthorized commercial use, re-packaging, or distribution of these specific assets for proprietary applications (e.g., App Store clones) is **strictly prohibited**.

---
*Created with ❤️ by Antigravity & Sparkle79*
