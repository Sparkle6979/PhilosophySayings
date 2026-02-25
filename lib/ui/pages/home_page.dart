import 'package:flutter/material.dart';
import '../../models/quote.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/llm_service.dart'; // DeepSeek Service
import '../../services/favorites_service.dart';
import '../../services/share_service.dart'; // Share Service
import '../widgets/quote_card.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'philosophers_chamber_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 服务层依赖 (Service Dependencies)
  // 此处将负责与大语言模型 (LLM) 通信的逻辑全部封装在了 LLMService 中，
  // 使得 UI 层代码与业务逻辑解耦，代码更干净。
  final LLMService _llmService = LLMService();

  // 用于截图分享功能的 GlobalKey，通过它能够抓取对应的 Widget 并生成图片。
  final GlobalKey _quoteCardKey = GlobalKey();

  bool _isLoading = false;
  Quote? _currentQuote;

  // --- 状态提升 (State Lifting) ---
  // 将原属于 "密室页面" (PhilosophersChamberPage) 的聊天记录状态提升到了 HomePage。
  // 这样做的目的是：当用户从密室返回首页后，聊天记录并不会因为密室页面的销毁而丢失。
  // Key: Quote.text (用名言文本作为唯一标识)
  // Value: 聊天记录列表
  final Map<String, List<Map<String, String>>> _chatHistories = {};

  // --- 异步状态管理 ---
  // Future 是 Dart 中处理异步操作的核心机制。
  // _quoteFuture：表示当前正在屏幕上显示（或正在加载准备显示）的名言。
  // _nextQuoteFuture：这是一种【预加载思想】。在用户阅读当前名言时，后台已经开始默默请求下一条了。
  // 这样当用户点击“寻觅”时，能瞬间完成切换，极大提升了流畅体验。
  late Future<Quote> _quoteFuture;
  late Future<Quote> _nextQuoteFuture;

  @override
  void initState() {
    super.initState();
    // 首屏加载：同时请求两条
    _quoteFuture = _llmService.fetchRandomQuote();
    _nextQuoteFuture = _llmService.fetchRandomQuote();
  }

  Future<void> _shareQuote() async {
    if (_currentQuote == null) return;

    try {
      // Show loading indicator or feedback if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating image for sharing...'),
          duration: Duration(milliseconds: 800),
        ),
      );

      await ShareService.captureAndShare(_quoteCardKey);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _loadNewQuote() {
    setState(() {
      _isLoading = true; // Set loading state
      // 1. 制造“寻觅感” (Artificial Delay)
      // 即使数据已经预加载好了，也强制展示 800ms Loading，让用户感觉“正在寻找”
      final readyFuture = _nextQuoteFuture;
      _quoteFuture = Future.delayed(const Duration(milliseconds: 500), () async {
        var quote = await readyFuture;

        // Debugging Duplicates:
        // If pre-loaded quote is identical to current (likely due to race condition in exclusion list),
        // discard it and fetch a fresh one.
        if (_currentQuote != null && quote.text == _currentQuote!.text) {
          print(
            "⚠️ Duplicate quote detected (Pre-load race condition). Fetching fresh...",
          );
          try {
            // Forced fresh fetch
            quote = await _llmService.fetchRandomQuote();
          } catch (e) {
            print("❌ Failed to fetch fresh quote on duplicate: $e");
            rethrow;
          }
        }

        _currentQuote = quote; // Update current quote
        _isLoading = false; // Reset loading state
        return quote;
      });

      // 2. 立即开始预加载下一条 (在后台进行)
      _nextQuoteFuture = _llmService.fetchRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 浅灰背景，更有质感
      appBar: AppBar(
        // title: const Text('Philosophy Sayings'),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 装饰性花纹 (Typographic Decoration)
            const Text(
              '— ❦ —',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black45,
                fontWeight: FontWeight.w300,
                letterSpacing: 2.0,
              ),
            ),
            // 主标题
            Text(
              'PHILOSOPHY SAYINGS',
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // 透明 AppBar 现代感更强
        foregroundColor: Colors.black, // 黑色文字
        toolbarHeight: 50, // 进一步减小高度 (50 -> 40)
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              size: 20,
              color: Colors.black54,
            ),
            tooltip: "分享哲思",
            onPressed: _shareQuote,
          ),
          const SizedBox(width: 8), // Spacing
          IconButton(
            icon: const Icon(
              Icons.bookmarks_rounded,
              color: Colors.black54,
              size: 20,
            ), // 稍微减小图标并变淡
            tooltip: "哲思收藏",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black54,
              size: 20,
            ),
            tooltip: "设置",
            onPressed: () async {
              // Navigate to Settings Page
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              // Upon return, reload LLM Config
              if (mounted) {
                setState(() {
                  _llmService.reloadConfig();
                  // Optionally reload quote if needed, but not strictly necessary
                  // _loadNewQuote();
                });
              }
            },
          ),
          const SizedBox(width: 8), // 右侧边距微调
        ],
      ),
      body: FutureBuilder<Quote>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          // 1. 加载中 (Thematic Loading)
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minimalist Pulse Animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.3, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    onEnd:
                        () {}, // Loop handled by widget state if needed, but simple fade is enough for short waits
                    child: const Icon(
                      Icons.auto_awesome, // Sparkle/Star icon
                      size: 32,
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Visiting the Omniscient Sea...", // More poetic
                    style: GoogleFonts.imFellEnglishSc(
                      color: Colors.black45,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "正在造访全知之海...",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. 错误处理
          if (snapshot.hasError) {
            _showError("发生了时空扰动: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("发生了时空扰动: ${snapshot.error}"),
                  TextButton(onPressed: _loadNewQuote, child: const Text("重试")),
                ],
              ),
            );
          }

          // 3. 数据加载成功
          if (snapshot.hasData) {
            _currentQuote = snapshot.data!; // Ensure _currentQuote is updated
            return Column(
              children: [
                // 1. Quote Card Area (Wrapped for Capture)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0), // 顶部固定间距
                    child: SingleChildScrollView(
                      child: RepaintBoundary(
                        key: _quoteCardKey,
                        child: QuoteCard(quote: _currentQuote!),
                      ),
                    ),
                  ),
                ),

                // 2. 底部悬浮胶囊栏 (Floating Capsule Bar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30, top: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.95,
                      ), // High opacity for contrast
                      borderRadius: BorderRadius.circular(50), // Capsule shape
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ListenableBuilder(
                      listenable: FavoritesService(),
                      builder: (context, _) {
                        final isFav = FavoritesService().isFavorite(
                          snapshot.data!,
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Left: Like
                            _buildCapsuleAction(
                              icon: isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_rounded,
                              label: isFav ? "已共鸣" : "共鸣",
                              color: isFav ? Colors.redAccent : Colors.black87,
                              onTap: () {
                                if (isFav) {
                                  FavoritesService().remove(snapshot.data!);
                                } else {
                                  FavoritesService().add(snapshot.data!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("已收藏到心中的圣殿"),
                                      duration: Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      width: 300,
                                    ),
                                  );
                                }
                              },
                            ),

                            // Center: Anchor (Primary)
                            Container(
                              height: 36, // Vertical divider
                              width: 1,
                              color: Colors.black12,
                            ),

                            _buildCapsuleAction(
                              icon: Icons.vpn_key_rounded,
                              label: "锚定",
                              isPrimary: true,
                              onTap: () {
                                if (snapshot.data == null) return;
                                final quote = snapshot.data!;
                                final history = _chatHistories[quote.text];
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(
                                      milliseconds: 1000,
                                    ), // Slower, deeper transition
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => PhilosophersChamberPage(
                                          quote: quote,
                                          initialHistory: history,
                                          onChatUpdated: (newHistory) {
                                            _chatHistories[quote.text] =
                                                newHistory;
                                          },
                                        ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              },
                            ),

                            Container(
                              height: 36, // Vertical divider
                              width: 1,
                              color: Colors.black12,
                            ),

                            // Right: Explore
                            _buildCapsuleAction(
                              icon: Icons.explore_outlined,
                              label: "寻觅",
                              onTap: _loadNewQuote,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCapsuleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isPrimary ? Colors.black : color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w600,
                color: isPrimary ? Colors.black : color.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
