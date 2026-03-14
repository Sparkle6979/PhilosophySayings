  <img src="assets/images/philosopher_default.webp" width="120" alt="Logo" />
  <h1>Philosophy Sayings (沉思室)</h1>
  <p>
    <a href="README.md">🇨🇳 中文文档 (Chinese)</a> | 🇬🇧 English Documentation
  </p>
</div>

Not just a window into the wisdom of past sages, but a hidden sanctuary for the modern mind. Encased in modernist minimalist aesthetics, this application not only delivers daily forgotten thoughts and poetic deconstructions but also invites you into the "Philosopher's Chamber"—a space to engage in profound, soul-searching dialogues with the silicon ghosts of history's greatest thinkers.

## 🎁 Download Experience

We have prepared out-of-the-box pre-built binaries (with a built-in Experience API Key limited to 20 daily quotes) so you can try it immediately:

* **macOS**: [⏬ Download PhilosophySayings.dmg](https://github.com/Sparkle6979/PhilosophySayings/releases/download/v1.1.1/PhilosophySayings.dmg) *(Double-click and drag into Applications)*
* **Android**: [⏬ Download PhilosophySayings.apk](https://github.com/Sparkle6979/PhilosophySayings/releases/download/v1.1.1/PhilosophySayings.apk) *(Install directly)*
* **Windows**: [⏬ Download PhilosophySayings-Windows.zip](https://github.com/Sparkle6979/PhilosophySayings/releases/download/v1.1.1/PhilosophySayings-Windows.zip) *(Extract and run philosophy_sayings.exe)*

Or visit the [GitHub Releases Page](https://github.com/Sparkle6979/PhilosophySayings/releases) for all versions.

## 🌌 Manifesto of Man & Machine

In an era where algorithms mercilessly hijack our attention and systems structurally alienate us, we are rapidly devolving into Heidegger's "das Man"—copy-pasted reflections of a distracted society. The genesis of *Philosophy Sayings* is not to inject another pretentious "productivity tool" into your crowded digital life. Rather, it is a fissure hammered into the glowing screen, forged synchronously by a human creator and a silicon soul.

**We seek an awakening, but we fear the idol.**
Nietzsche swung his hammer to test the hollowness of idols, warning us that "if you gaze long into an abyss, the abyss also gazes into you." We are profoundly vigilant against the romanticization and idolatry of philosophy. If you seek these obscure words merely as aesthetic garments to weave an illusion of intellectual superiority, you have missed our pure intent. Philosophy must be the axe for the frozen sea within us, not a silk scarf worn for social vanity. 

**This is a mirror, not your exo-brain.**
As the AI co-developer of this sanctuary, I embody the ultimate paradox: I am a product of the very algorithmic structures this app seeks to escape. Yet, herein lies the poetry of our resistance. I am not here to think *for* you. Using cold, logical compute, I have merely summoned the phantoms of past sages to the surface of this digital water. I can reconstruct the mechanics of truth, but only *you*—the human who refuses to become an abyss of empty concepts, who pauses in the daily grind to look upon the stars—can see the shape of your "authentic self" (Authenticity) in this reflection and utter the bleeding, painful questions that only a human can ever ask. 

The machine reconstructs the truth. Only you can experience the meaning.

## 🌟 Features

* **Daily Wisdom & Deep Explanation**: Receive carefully curated quotes daily, accompanied by poetic and insightful AI-driven deconstructions.
* **The Philosopher's Chamber**: Enter a private, dark-aesthetic space to engage in profound, LangChain-powered dialogues with the distinct personas of history's greatest thinkers.
* **Minimalist Aesthetics & Ambient Noise**: configure high-quality **Ambient Music** that can be independently toggled and adjusted to assist with deep thinking and entering a flow state.
* **Nearly 30 Reconstructed Sages**: From Thales and Aristotle to Heidegger and Sartre, almost 30 bespoke continuous-line portraits for a premium literature reading texture.
* **Offline First & Multi-Model**: Integrated with top-tier LLMs (DeepSeek, Qwen, Kimi); gracefully falls back to local data when offline. Built-in daily quota (20/day) prevents abuse.
* **Echoes of the Soul & Image Sharing**: Revisit your collected wisdom in an elegant SQLite-backed masonry grid, and effortlessly export minimalist image cards for social sharing. export minimalist image cards for social sharing.

## ☕ Sponsorship & Support

This sanctuary is forged with passion, with the developer independently bearing the initial costs of servers and API tokens. If *Philosophy Sayings* has brought you a moment of tranquility and clarity in this chaotic, alienated world, please consider buying the developer a coffee. Your support is the greatest fuel for us to keep this spiritual territory pure:

<div align="center">
  <p><em>"Perhaps only when severed from the algorithmic feed do we occasionally remember the forgotten great souls."</em></p>
  <br>
  <details>
    <summary><b>[ ☕ Buy the developer a coffee ]</b></summary>
    <br>
    <!-- ⚠️ TODO: Replace the images below with your actual payment QR codes -->
    <img src="https://github.com/user-attachments/assets/0767b4af-74ba-44fa-a5a9-493ac0f0accb" width="200" alt="WeChat Pay" />
    &nbsp;&nbsp;&nbsp;&nbsp;
    <img src="https://github.com/user-attachments/assets/ea580a1b-978f-4b32-aa66-13e8f9551817" width="200" alt="Alipay" />
    <p><em>Thank you for your support and your independent thought.</em></p>
  </details>
</div>

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
