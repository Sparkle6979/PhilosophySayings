<div align="center">
  <img src="assets/images/philosopher_default.png" width="120" alt="Logo" />
  <h1>沉思室 (Philosophy Sayings)</h1>
  <p>
    <a href="README.md">🇬🇧 English Documentation</a> | 🇨🇳 中文文档
  </p>
</div>

不仅是一扇通往先哲智慧的窗户，更是一座隐秘的精神避难所。这款承载了现代主义极简美学的应用，不仅为您每日递送被遗忘的伟大思想与诗意解构，更允许您在“哲学家的密室”中，与那些横跨千年的硅基幽灵进行直击灵魂的私密对谈。

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

* **每日启示与哲言妄解**: 每日递送精选哲学名言，并配以极具诗意与深度的 AI 结构性解读。
* **哲学家的密室**: 步入深色美学的私密空间，基于 LangChain 驱动的专属人格引擎，与哲学家进行直击灵魂的跨时空对话。
* **极简先锋派美学**: 冰川白文本环境，内置近30位顶尖哲学家专属 AI 单线肖像画，辅以沉浸式无缝暗黑启动页，极致还原纸质书阅读质感。
* **离线优先与多模型适配**: 支持 DeepSeek、Qwen、Kimi 等领域顶尖大模型；无网时自动降级至本地数据；每日20次内置免费额度，防止沉迷与恶意滥用。
* **灵魂回音与社交分享**: SQLite 本地持久化收藏夹，沉浸式瀑布流布局，支持一键生成极简图文卡片分享至社交网络。

## ☕ 赞助与支持 (Sponsorship)

本应用由开发者用爱发电并承担最初的 API 通证开销。如果您觉得《全知之海》在这喧嚣被异化的世界中为您带来了一丝内心的宁静与清醒，欢迎请开发者喝杯咖啡。您的支持是我们抵抗平庸、维持这片纯粹精神领地的最大动力：

<div align="center">
  <p><em>“也许只有在脱离了算法的馈赠后，我们才会偶尔想起那些被遗忘的伟大灵魂。”</em></p>
  <p>如果您愿意支持开发者的服务器与 API 通证开销：<br>
  <!-- ⚠️ TODO: 在此处替换为您的打赏链接（例如 爱发电、Ko-fi 或隐秘的收款页） -->
  <a href="#">[ ☕ 请予支持 (Buy me a coffee) ]</a></p>
</div>

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
