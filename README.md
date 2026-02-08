# Philosophy Sayings (全知之海)

An immersive, aesthetically pleasing Flutter application that delivers daily philosophical quotes with deep, AI-powered explanations.

## 🌟 Features

### Core Experience
*   **Daily Wisdom**: Display curated quotes from great philosophers (e.g., Nietzsche, Camus).
*   **Deep Explanation (哲言妄解)**: Poetic and insightful breakdowns of the meaning behind each quote.
*   **Existentialism Bias**: Optimized prompts to explore themes of modern nihilsm, focus on Nietzsche, Camus, Heidegger, Sartre, and Kierkegaard.
*   **DeepSeek Integration**: Powered by the DeepSeek-V3/R1 model for profound, nuanced philosophical generation.

### The Philosopher's Chamber (哲学家的密室)
*   **Immersive Chat**: Step into a private "chamber" to converse directly with the philosopher who authored the quote.
*   **Persona Engine**: Each philosopher has a distinct personality (Prompt Engineering via `lib/config/prompts.dart`).
*   **Contextual Opening**: The philosopher initiates the conversation based on the specific quote you are viewing.
*   **Persistence**: Chat sessions are saved per quote, allowing you to leave and return to the conversation later.

### Utilities
*   **Echoes of the Soul (收藏夹)**: A dedicated space to revisit your collected wisdom, featuring a bilingual "Masonry" grid layout.
*   **Share as Image**: Convert your current wisdom into a beautiful image card for social sharing.
*   **Dynamic Assets**: Smart mapping of philosopher names to local asset images.

## 🛠 Tech Stack
*   **Framework**: Flutter (Dart)
*   **AI Engine**: LangChain.dart + DeepSeek API
*   **State Management**: `Provider` + `State Lifting`
*   **Persistence**: `shared_preferences` (Settings) + In-Memory Map (Chat History) -> *SQLite planned for future*
*   **UI/UX**: Custom Animations (Breathing Pulse), Glassmorphism, Adaptive Layouts.

---

## 📅 Development Status

### Phase 1: Foundation (DONE ✅)
*   [x] **AI Integration**: Connected `LLMService` to DeepSeek via LangChain.dart.
*   [x] **Content Filtering**: Implemented "Recent History" tracking to avoid duplicate authors and quotes.
*   [x] **Refined Prompts**: Extracted all system prompts to `lib/config/prompts.dart` for easy tuning.

### Phase 2: Design & Aesthetics (DONE ✅)
*   [x] **Visual Identity**: Implemented "Rugged Romantic" theme with `IM Fell English SC` typography.
*   [x] **Animations**: Added "Philosophical Pulse" loading animation.
*   [x] **Adaptive UI**: Responsive layouts for both Mobile and Desktop.

### Phase 3: The "Consultation Room" (DONE ✅)
*   [x] **Philosopher's Chamber**: Full chat interface with streaming-like UX.
*   [x] **Session Persistence**: Chat history is preserved during the app session.

---

## 🚀 Getting Started

1.  **Prerequisites**: Flutter SDK installed.
2.  **API Key Setup**:
    Get your API Key from [DeepSeek Platform](https://platform.deepseek.com/).
    
    You have two options to inject the key:

    **Option A: Command Line (Recommended)**
    ```bash
    flutter run --dart-define=DEEPSEEK_API_KEY=your_actual_key_here
    ```

    **Option B: Environment Variable (VS Code)**
    Add this to your `.vscode/launch.json`:
    ```json
    "args": [
        "--dart-define=DEEPSEEK_API_KEY=your_actual_key_here"
    ]
    ```

3.  **Run**:
    ```bash
    flutter pub get
    flutter run -d macos
    ```

---
*Created with ❤️ by Antigravity & Sparkle79*
