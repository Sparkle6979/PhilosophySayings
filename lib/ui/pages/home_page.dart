import 'package:flutter/material.dart';
import '../../models/quote.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/llm_service.dart'; // DeepSeek Service
import '../../services/favorites_service.dart';
import '../../services/share_service.dart'; // Share Service
import '../widgets/quote_card.dart';
import 'favorites_page.dart';
import 'philosophers_chamber_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LLMService _llmService = LLMService();
  final GlobalKey _quoteCardKey = GlobalKey(); // Key for capturing image
  bool _isLoading = false;
  Quote? _currentQuote;
  // Store chat history for each quote to persist session
  // State Lifting: 将聊天记录提升到 HomePage 管理
  // Key: Quote.text (名言内容作为唯一标识)
  // Value: 聊天记录列表
  final Map<String, List<Map<String, String>>> _chatHistories = {};

  // Future 用于存储异步操作的状态
  late Future<Quote> _quoteFuture;
  late Future<Quote> _nextQuoteFuture; // 预加载的下一条

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
      _quoteFuture = Future.delayed(
        const Duration(milliseconds: 800),
        () async {
          final quote = await readyFuture;
          _currentQuote = quote; // Update current quote
          _isLoading = false; // Reset loading state
          return quote;
        },
      );

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

                // 2. 底部操作栏 (Action Bar)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 18,
                    bottom: 18, // Reduced from 20 to 10 to be "lower"
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
                          // 左侧：共鸣按钮 (Resonate / Like)
                          SizedBox(
                            height: 40,
                            child: FloatingActionButton.extended(
                              heroTag: "like",
                              onPressed: () {
                                if (isFav) {
                                  FavoritesService().remove(snapshot.data!);
                                } else {
                                  FavoritesService().add(snapshot.data!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("已收藏到心中的圣殿"),
                                      duration: Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      width: 400,
                                    ),
                                  );
                                }
                              },
                              backgroundColor: isFav
                                  ? Colors.redAccent
                                  : Colors.white,
                              foregroundColor: isFav
                                  ? Colors.white
                                  : Colors.redAccent,
                              elevation: 2,
                              extendedPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                size: 18,
                              ),
                              label: Text(
                                isFav ? "已共鸣" : "共鸣",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          // 中间：密室锚点 (Anchor / Chamber) - Primary Action
                          SizedBox(
                            height: 40,
                            child: FloatingActionButton.extended(
                              heroTag: "anchor",
                              onPressed: () {
                                if (snapshot.data == null) return;
                                final quote = snapshot.data!;
                                // Retrieve existing history or null
                                // [持久化逻辑]: 在进入密室前，先检查 memory 中是否有这句名言的聊天记录
                                final history = _chatHistories[quote.text];

                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => PhilosophersChamberPage(
                                          quote: quote,
                                          initialHistory: history, // 将历史记录传入子页面
                                          onChatUpdated: (newHistory) {
                                            // [状态同步]: 子页面 (ChamberPage) 产生新消息时，回调此函数更新父页面状态
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
                                    transitionDuration: const Duration(
                                      milliseconds: 800,
                                    ),
                                  ),
                                );
                              },
                              backgroundColor:
                                  Colors.white, // Reverted to white
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              extendedPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              icon: const Icon(Icons.vpn_key_rounded, size: 18),
                              label: const Text(
                                "锚定",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              tooltip: "进入密室",
                            ),
                          ),

                          // 右侧：再探索按钮 (Explore / Search) - Secondary
                          SizedBox(
                            height: 40,
                            child: FloatingActionButton.extended(
                              heroTag: "explore",
                              onPressed: _loadNewQuote,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              extendedPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              icon: const Icon(
                                Icons.explore_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                "寻觅",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
}
