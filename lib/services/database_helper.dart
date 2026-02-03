import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quote.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 获取数据库实例，如果不存在则初始化
  Future<Database> get database async {
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
      version: 2, // 升级版本号
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 首次创建数据库时执行 SQL 建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        text TEXT,
        author TEXT,
        tagline TEXT,
        explanation TEXT,
        imageUrl TEXT,
        bio TEXT,
        timestamp INTEGER
      )
    ''');
  }

  /// 数据库升级逻辑
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE favorites ADD COLUMN tagline TEXT');
    }
  }

  // --- CRUD Operations ---

  /// 插入金句
  Future<int> insertQuote(Quote quote) async {
    final db = await database;
    // 使用 uuid 或 text 的哈希作为 ID
    final id = quote.text.hashCode.toString();
    final data = quote.toJson();
    data['id'] = id;
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    // ConflictAlgorithm.replace: 如果 ID 重复则覆盖
    return await db.insert(
      'favorites',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除金句
  Future<int> deleteQuote(String text) async {
    final db = await database;
    final id = text.hashCode.toString();
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有收藏
  Future<List<Quote>> getFavorites() async {
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
