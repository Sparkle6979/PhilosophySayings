import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quote.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String _webPrefsKey = 'web_favorites';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 获取数据库实例，如果不存在则初始化
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web, using SharedPreferences instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库: 设置路径、版本、创建表
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 4, // 升级版本号
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            text TEXT,
            author TEXT,
            tagline TEXT,
            explanation TEXT,
            imageUrl TEXT,
            bio TEXT,
            life_years TEXT,
            theme TEXT,
            isMock INTEGER,
            timestamp INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE favorites ADD COLUMN tagline TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE favorites ADD COLUMN life_years TEXT');
          await db.execute('ALTER TABLE favorites ADD COLUMN theme TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE favorites ADD COLUMN isMock INTEGER');
        }
      },
    );
  }

  // --- CRUD Operations ---

  /// 插入金句
  Future<int> insertQuote(Quote quote) async {
    final id = quote.text.hashCode.toString();
    final data = quote.toJson();
    data['id'] = id;
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webPrefsKey) ?? '[]';
      final List<dynamic> list = jsonDecode(str);
      list.removeWhere((item) => item['id'] == id);
      list.add(data);
      await prefs.setString(_webPrefsKey, jsonEncode(list));
      return 1;
    }

    final db = await database;
    return await db.insert(
      'favorites',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除金句
  Future<int> deleteQuote(String text) async {
    final id = text.hashCode.toString();

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webPrefsKey) ?? '[]';
      final List<dynamic> list = jsonDecode(str);
      list.removeWhere((item) => item['id'] == id);
      await prefs.setString(_webPrefsKey, jsonEncode(list));
      return 1;
    }

    final db = await database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有收藏
  Future<List<Quote>> getFavorites() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webPrefsKey) ?? '[]';
      final List<dynamic> list = jsonDecode(str);
      list.sort((a, b) => (b['timestamp'] as int? ?? 0).compareTo((a['timestamp'] as int? ?? 0)));
      return list.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      orderBy: "timestamp DESC", // 按时间倒序
    );

    return List.generate(maps.length, (i) {
      return Quote.fromJson(maps[i]);
    });
  }
}
