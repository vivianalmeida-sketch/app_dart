import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();

  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('newpay.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receiverName TEXT NOT NULL,
        receiverKey TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'name': 'Nathan Viana',
      'email': 'newpay@teste.com',
      'password': '123456',
      'balance': 2450.75,
    });
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;

    final result = await db.query(
      'users',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> saveTransfer({
    required String receiverName,
    required String receiverKey,
    required double amount,
    required String description,
  }) async {
    final db = await database;

    await db.insert('transfers', {
      'receiverName': receiverName,
      'receiverKey': receiverKey,
      'amount': amount,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTransfers() async {
    final db = await database;

    return await db.query(
      'transfers',
      orderBy: 'id DESC',
    );
  }

  Future<void> updateBalance(double newBalance) async {
    final db = await database;

    await db.update(
      'users',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}