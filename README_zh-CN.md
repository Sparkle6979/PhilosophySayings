<div align="center">
  <img src="assets/images/philosopher_default.png" width="120" alt="Logo" />
  <h1>沉思室 (Philosophy Sayings)</h1>
  <p>
    <a href="README.md">🇬🇧 English Documentation</a> | 🇨🇳 中文文档
  </p>
</div>

一款沉浸式、极具美感的 Flutter 应用程序，为您提供每日哲学名言，并配以由 AI 驱动的深度解读。

## 🌟 核心功能 (Features)

### 核心体验 (Core Experience)
*   **每日启示 (Daily Wisdom)**: 展示由伟大哲学家（如尼采、加缪、海德格尔）精心挑选的名言。
*   **哲言妄解 (Deep Explanation)**: 对每句名言背后的含义进行富有诗意和深刻的解构。
*   **存在主义偏好 (Existentialism Bias)**: 优化的提示词，重点探索现代虚无主义主题，聚焦于存在主义者和古典思想家。
*   **动态资产系统 (Dynamic Assets System)**: 智能地将哲学家名字映射到本地图片资源，并附带随机的高质量变体。
*   **多模型支持 (Multi-Model Support)**: 集成了国内顶尖大语言模型能力，包含 DeepSeek, 通义千问 (Qwen), MiniMax, 以及 月之暗面 (Moonshot/Kimi)。
*   **离线优先 / 优雅降级 (Offline First / Degradation)**: 当无网络或 API Token 耗尽时，优雅地降级至丰富的本地模拟数据（带有 "SAMPLE / 示例" 标识）。
*   **体验模式防滥用机制 (Rate Limiter)**: 设计了极其克制的、无侵入系统弹窗的每日额度限制 (20次/天)，兼顾了新用户的沉浸体验与物理防盗刷。

### 哲学家的密室 (The Philosopher's Chamber)
*   **沉浸式对话 (Immersive Chat)**: 步入一个私密的“密室”（深色美学 UI），直接与说出该名言的哲学家进行对话。
*   **人格引擎 (Persona Engine)**: 每位哲学家都拥有基于 LangChain.dart 驱动的独特人格（通过 `lib/config/prompts.dart` 设置）。
*   **语境开场白 (Contextual Opening)**: 哲学家会根据您当前正在阅读的具体名言来主动开启对话。
*   **会话持久化 (Session Persistence)**: 在应用程序的单次运行周期内（状态提升），针对每条名言保存对话历史。

### 实用工具与交互体验 (Utilities & UX)
*   **灵魂回音 (收藏夹 / Echoes of the Soul)**: 一个专门用来重温您收集的智慧的空间，采用瀑布流布局并支持 SQLite 本地持久化。
*   **分享为图片 (Share as Image)**: 将当前的智慧语录转化为精美的图文卡片，以便在社交媒体分享 (`RepaintBoundary`)。
*   **无缝暗黑启动页 (Seamless Dark Splash Screen)**: 采用 `flutter_native_splash` 消除白屏闪烁，实现沉浸式加载体验。
*   **自适应布局 (Adaptive Layouts)**: 在 macOS 桌面端应用和标准移动卡片界面之间实现无缝响应。

## 🏗 架构与语义分层 (Architecture)

代码库采用了健壮且语义明确的分层设计以实现关注点分离：
*   `lib/config/`: 配置文件与解耦的 AI 提示词 (`prompts.dart`)。
*   `lib/models/`: 纯 Dart 数据结构 (`quote.dart`, `llm_config.dart`)。
*   `lib/services/`: 与 UI 解耦的核心业务逻辑层：
    *   `llm_service.dart`: LangChain 集成与大语言模型流水线。
    *   `database_helper.dart` & `favorites_service.dart`: SQLite 本地存储。
    *   `preference_service.dart`: 用于设置项的 SharedPreferences。
*   `lib/ui/pages/`: 应用程序的主屏幕 (`home_page.dart`, `settings_page.dart`, `philosophers_chamber_page.dart`)。
*   `lib/ui/widgets/`: 可复用的 UI 组件 (`quote_card.dart`)。
*   `lib/utils/`: 纯净的辅助函数集（例如用于稳健的、基于 AST 级别的 JSON 修复的 `json_utils.dart`）。

*(注：代码库的关键部分，特别是 LangChain 逻辑和状态管理，包含了极其详尽的中文教学级注释，旨在帮助初次接触这些框架的开发者。)*

## 🚀 快速开始 (Getting Started)

1.  **环境要求 (Prerequisites)**: 已安装 Flutter SDK。
2.  **运行应用 (Run the App)**:
    ```bash
    flutter pub get
    flutter run
    ```
3.  **API 密钥设置 (需要提供真实 AI 驱动) / API Key Setup**:
    默认情况下，**体验模式 (Experience Mode)** 需要在代码 `llm_service.dart` 中硬编码 API Key（已于开源版脱敏）。
    或者您可以：
    *   前往 **设置 (Settings)** (首页的齿轮图标)。
    *   切换为 **极速模式 (Speed Mode)**。
    *   选择您的模型服务商 (DeepSeek, 通义千问 Qwen, MiniMax, 或 月之暗面 Kimi) 并输入您的专属 API Key。
    *   您的 API Key 将通过 `SharedPreferences` 安全地暂存在本地。

---
*Created with ❤️ by Antigravity & Sparkle79*
