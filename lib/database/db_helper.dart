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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        receiverName TEXT NOT NULL,
        receiverKey TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'name': 'Vivian Cristina',
      'email': 'newpay@teste.com',
      'password': '123456',
      'balance': 2450.75,
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('CREATE UNIQUE INDEX idx_users_email ON users(email)');
      } catch (_) {}
    }

    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE transfers ADD COLUMN userId INTEGER NOT NULL DEFAULT 0',
        );
      } catch (_) {}
    }
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

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;

    final existingUser = await getUserByEmail(email);

    if (existingUser != null) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    final newUserId = await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'balance': 50.00,
    });

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [newUserId],
    );

    return result.first;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;

    final result = await db.query('users', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> saveTransfer({
    required int userId,
    required String receiverName,
    required String receiverKey,
    required double amount,
    required String description,
  }) async {
    final db = await database;

    await db.insert('transfers', {
      'userId': userId,
      'receiverName': receiverName,
      'receiverKey': receiverKey,
      'amount': amount,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTransfers(int userId) async {
    final db = await database;

    return await db.query(
      'transfers',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<void> updateBalance({
    required int userId,
    required double newBalance,
  }) async {
    final db = await database;

    await db.update(
      'users',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;

    return await db.query('users', orderBy: 'name ASC');
  }
}
