# Philosophy Sayings (全知之海)

An immersive, aesthetically pleasing Flutter application that delivers daily philosophical quotes with deep, AI-powered explanations.

## 🌟 Features (Current Status)

### Core Experience
*   **Daily Wisdom**: Display curated quotes from great philosophers (e.g., Nietzsche, Camus).
*   **Deep Explanation (深度解析)**: Poetic and insightful breakdowns of the meaning behind each quote.
*   **Existentialism Bias**: Optimized prompts to explore themes of modern nihilsm, focus on Nietzsche, Camus, Heidegger, Sartre, and Kierkegaard.
*   **Immersive Layouts**: 
    *   **Magazine Mode**: An elegant split-screen layout for desktop/tablet (Portrait on left, Quote on right).
    *   **Adaptive UI**: Automatically switches between mobile-first column and desktop-first row layouts.
*   **Smart Dynamic Asset Mapping**: 
    *   Utilizes `AssetManifest` for runtime discovery.
    *   Eliminates hard-coding; just drop a file into `assets/images/philosopher_*.png` and it works.

### Interactions
*   **传递 (Transmit/Share)**: Convert your current wisdom into a beautiful image card for social sharing (Powered by `RepaintBoundary` & `share_plus`).
*   **Resonate (共鸣)**: Save your favorite quotes to a local SQLite database (`sqflite`).
*   **Favorites Manager**: A dedicated space to revisit your collected wisdom.

## 🛠 Tech Stack
*   **Framework**: Flutter (Dart)
*   **AI Engine**: LangChain.dart + DeepSeek (Real-time generation)
*   **Persistence**: SQLite (`sqflite`) for favorites and history tracking.
*   **Asset Management**: Custom AI-generated minimalist line art portraits.

---

## 📅 Progress Tracking

### Phase 1: Persistence & Real Data (DONE ✅)
*   [x] **Local Database**: Integrated `sqflite` for favorited quotes.
*   [x] **AI Integration**: Connected `LLMService` to DeepSeek via LangChain.dart.
*   [x] **Content Filtering**: Implemented "Recent History" tracking to avoid duplicate authors and quotes.

### Phase 2: Design & Aesthetics (DONE ✅)
*   [x] **Magazine Layout**: Implemented adaptive layouts for cross-platform elegance.
*   [x] **Share as Image**: Fully functional sharing mechanism for macOS (and other platforms).
*   [x] **Dynamic Assets**: Refactored asset loader to be decoupled and scaleable.

### Phase 3: The "Consultation Room" (Philosopher's Chat - IN PROGRESS 🏗️)
*   [ ] **Persona Chat**: Real-time conversation with specific philosophers.
*   [ ] **Customized Styles**: More diverse portrait styles and themes.

---

## 🚀 Getting Started

1.  **Prerequisites**: Flutter SDK installed.
2.  **Run**:
    ```bash
    flutter pub get
    flutter run -d macos
    ```

---
*Created with ❤️ by Antigravity & User*
