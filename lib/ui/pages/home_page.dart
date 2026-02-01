import 'package:flutter/material.dart';
import '../../models/quote.dart';
import '../../services/llm_service.dart';
import '../../services/favorites_service.dart';
import '../widgets/quote_card.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LLMService _llmService = LLMService();

  // Future 用于存储异步操作的状态，FutureBuilder 会监听这个 Future
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _loadNewQuote();
  }

  void _loadNewQuote() {
    setState(() {
      _quoteFuture = _llmService.fetchRandomQuote();
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
            if (snapshot.connectionState == ConnectionState.waiting) {
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
              return Column(
                children: [
                  Expanded(child: QuoteCard(quote: snapshot.data!)),

                  // 底部操作栏
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // 均匀分布，明确左右
                      children: [
                        // 左侧：略过按钮 (Pass) - 保持简洁，灰色调
                        FloatingActionButton(
                          heroTag: "pass",
                          onPressed: _loadNewQuote,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.close, size: 28),
                        ),

                        // 右侧：共鸣按钮 (Like) - 改为柔和的白色背景 + 红色图标，避免黑色突兀感
                        FloatingActionButton.extended(
                          heroTag: "like",
                          onPressed: () {
                            // 保存到收藏
                            FavoritesService().add(snapshot.data!);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("已收藏到心中的圣殿"),
                                duration: Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating, // 悬浮样式更现代
                              ),
                            );
                            _loadNewQuote(); // 喜欢后也跳到下一个
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent, // 图标和文字颜色
                          elevation: 4,
                          icon: const Icon(Icons.favorite_rounded),
                          label: const Text(
                            "共鸣",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
