import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import 'database_helper.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;

  FavoritesService._internal() {
    _init();
  }

  List<Quote> _favorites = []; // 内存缓存，用于快速 UI 构建
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Quote> get favorites => _favorites;

  /// 初始化：从数据库加载数据
  Future<void> _init() async {
    _favorites = await _dbHelper.getFavorites();
    notifyListeners();
  }

  /// 添加收藏
  Future<void> add(Quote quote) async {
    if (isFavorite(quote)) return;

    // 1. 存入数据库
    await _dbHelper.insertQuote(quote);

    // 2. 更新内存缓存 (加到头部)
    _favorites.insert(0, quote);
    notifyListeners();
  }

  /// 移除收藏
  Future<void> remove(Quote quote) async {
    // 1. 从数据库移除
    await _dbHelper.deleteQuote(quote.text);

    // 2. 更新内存缓存
    _favorites.removeWhere((item) => item.text == quote.text);
    notifyListeners();
  }

  /// 检查是否收藏
  bool isFavorite(Quote quote) {
    return _favorites.any((item) => item.text == quote.text);
  }
}
