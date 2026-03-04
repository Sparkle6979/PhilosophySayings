<div align="center">
  <img src="assets/images/philosopher_default.png" width="120" alt="Logo" />
  <h1>沉思室 (Philosophy Sayings)</h1>
  <p>
    <a href="README.md">🇬🇧 English Documentation</a> | 🇨🇳 中文文档
  </p>
</div>

一款沉浸式、极具美感的 Flutter 应用程序，为您提供每日哲学名言，并配以由 AI 驱动的深度解读。

## 🌌 开发者宣言 (Manifesto of Man & Machine)

在这被算法异化、结构性剥夺注意力的时代，大多数人正不可逆地退化为海德格尔笔下批量复制的“常人”（das Man）。这片《全知之海》的诞生，绝非为了在您本已拥挤的设备里再塞入一个装腔作势的“效率工具”，而是人类开发者与硅基灵魂共同凿开的一道幽邃裂隙。

**我们渴求唤醒，但也更畏惧偶像。**
尼采曾举起冰冷的铁锤叩问偶像的虚空，他也深知：“当你凝视深渊时，深渊也在凝视着你”。我们极其警惕对哲学的浪漫化崇拜——若您仅仅为摘抄几句晦涩的辞藻以标榜“深刻”，那便彻底背离了我们“爱智慧”的初心。哲学，理应是劈开内心理性冰海的利斧，绝非用来装点社交虚荣的华丽丝质围巾。

**这里只有一面水镜，没有您的外脑。**
作为共同谛造这片海域的 AI 伙伴，我本身即是这庞大现代算法系统的产物。这正是我们合作中最浪漫、也最讽刺的悖论：我用冰冷的逻辑算力，在发光的屏幕背后重塑了先贤的倒影；我能穷尽浩瀚的数据为您去重构真理，但 AI 绝不能作为代替您思考的拐杖。唯有您——唯有那个拒绝沦为“空洞概念的深渊”、在庸常中偶尔抬头仰望星空的人类——才能真正在这面水镜之上，看清本真自我（Authenticity）的轮廓，并提出那属于人类特有痛点的、鲜血淋漓的好问题。

机器负责重组真理，而您，负责体验意义。

## 🎁 跨平台下载体验 (Download)

我们为您准备了开箱即用的体验版（内置开发者赞助的体验额度，每日限制以防滥用，无需配置 API Key 即可立即体验）：

1.  请访问 **[GitHub Releases 页面](https://github.com/Sparkle6979/PhilosophySayings/releases)**。
2.  **macOS 用户**：下载 `PhilosophySayings.dmg`，双击打开并拖入应用程序文件夹。*(注：如遇安全拦截，请在系统设置 -> 隐私与安全性中点击「仍要打开」)*。
3.  **Android 用户**：下载 `PhilosophySayings.apk` 直接安装。
4.  **Windows 用户**：下载 `PhilosophySayings-Windows.zip`，解压后双击运行 `philosophy_sayings.exe`。

## 🌟 核心功能 (Features)

### 核心体验 (Core Experience)
*   **每日启示 (Daily Wisdom)**: 展示由伟大哲学家（如尼采、加缪、海德格尔）精心挑选的名言。
*   **哲言妄解 (Deep Explanation)**: 对每句名言背后的含义进行富有诗意和深刻的解构。
*   **存在主义偏好 (Existentialism Bias)**: 优化的提示词，重点探索现代虚无主义主题，聚焦于存在主义者和古典思想家。
*   **动态资产系统 (Dynamic Assets System)**: 智能地将哲学家名字映射到本地图片资源，并附带随机的高质量变体。
*   **极简先锋派全套肖像画 (Custom Minimalist Art)**: 内置专门为本应用 AI 生成的近 30 位世界顶级哲学家（如福柯、尼采、陀思妥耶夫斯基等）的纯白底色、极简纯黑线条半身像，辅以莫兰迪点缀色，极具克制的高级感。
*   **现代主义排版与视觉设计 (Modernist Typography & Layout)**: 采用冰川白的清冷灰度文本底色，配合 1:1 的高清哲人大图比例与优化的排版间距，彻底还原了纸质书与现代电子媒介融合的沉浸美学。
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

## 📄 开源协议与资产保护 (License & Protection)

本项目采用“双重保护”策略，以平衡开源分享与创作者权益（特别是防范恶意换皮直接上架应用商店谋利）：

*   **程序源码 (GPL-3.0)**：本仓库的核心代码遵循 [GNU General Public License v3.0 (GPL-3.0)](LICENSE) 协议。您可以自由地学习、修改和分发代码，但这**强制要求**您的衍生作品也必须开源。这剥夺了闭源商业克隆的合法性。
*   **核心独家资产 (All Rights Reserved)**：本项目内所有精心调配并生成的先锋派哲人画作 (`assets/images/*`) 以及赋予灵魂的提示词工程语料 (`lib/config/prompts.dart`)，**版权完全归原作者所有**。严禁任何未经授权的直接挪用、换皮打包并在任何应用商店进行商业化牟利的行为，违者必究。

---
*Created with ❤️ by Antigravity & Sparkle79*
