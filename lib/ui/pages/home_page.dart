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
                    child: ListenableBuilder(
                      listenable: FavoritesService(),
                      builder: (context, _) {
                        final isFav = FavoritesService().isFavorite(
                          snapshot.data!,
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 左侧：共鸣按钮 (Resonate)
                            FloatingActionButton.extended(
                              heroTag: "like",
                              onPressed: () {
                                if (isFav) {
                                  // 已收藏 -> 取消收藏
                                  FavoritesService().remove(snapshot.data!);
                                } else {
                                  // 未收藏 -> 添加收藏
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

                            // 右侧：再探索按钮 (Explore)
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
