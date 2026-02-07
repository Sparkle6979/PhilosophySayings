import 'package:flutter/material.dart';
import '../../models/quote.dart';
import '../../services/llm_service.dart'; // DeepSeek Service
import '../../services/favorites_service.dart';
import '../../services/share_service.dart'; // Share Service
import '../widgets/quote_card.dart';
import 'favorites_page.dart';

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
        title: const Text('Philosophy Sayings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // 透明 AppBar 现代感更强
        foregroundColor: Colors.black, // 黑色文字
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Quote>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            // 1. 加载中
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoading) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("正在连接全知之海...", style: TextStyle(color: Colors.grey)),
                ],
              );
            }

            // 2. 错误处理
            if (snapshot.hasError) {
              _showError("发生了时空扰动: ${snapshot.error}");
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("发生了时空扰动: ${snapshot.error}"),
                  TextButton(onPressed: _loadNewQuote, child: const Text("重试")),
                ],
              );
            }

            // 3. 数据加载成功
            if (snapshot.hasData) {
              _currentQuote = snapshot.data!; // Ensure _currentQuote is updated
              return Column(
                children: [
                  // 2. Quote Card Area (Wrapped for Capture)
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
                          key: _quoteCardKey,
                          child: QuoteCard(quote: _currentQuote!),
                        ),
                      ),
                    ),
                  ),

                  // 底部操作栏
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
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
                            FloatingActionButton.extended(
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
                              elevation: 4,
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                              ),
                              label: Text(
                                isFav ? "已共鸣" : "共鸣",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 中间：再探索按钮 (Explore / Search) - Moved to Center
                            FloatingActionButton.extended(
                              heroTag: "explore",
                              onPressed: _loadNewQuote,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 4,
                              icon: const Icon(Icons.explore_outlined),
                              label: const Text(
                                "寻觅",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            // 右侧：分享按钮 (Share / Transmit) - Moved to Right, Renamed to "传递"
                            FloatingActionButton.extended(
                              heroTag: "share",
                              onPressed: _shareQuote,
                              backgroundColor: Colors.white, // White background
                              foregroundColor: Colors.black87, // Black icon
                              elevation: 4,
                              icon: const Icon(Icons.share_outlined),
                              label: const Text(
                                "传递", // Poetic name: Pass on/Transmit
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              tooltip: "传递哲思",
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
      ),
    );
  }
}
