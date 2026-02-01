import 'package:flutter/foundation.dart';
import '../models/quote.dart';

class FavoritesService extends ChangeNotifier {
  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final List<Quote> _favorites = [];

  List<Quote> get favorites => List.unmodifiable(_favorites);

  void add(Quote quote) {
    if (!_favorites.contains(quote)) {
      _favorites.add(quote);
      notifyListeners();
    }
  }

  void remove(Quote quote) {
    _favorites.remove(quote);
    notifyListeners();
  }

  bool isFavorite(Quote quote) {
    return _favorites.contains(quote);
  }
}
