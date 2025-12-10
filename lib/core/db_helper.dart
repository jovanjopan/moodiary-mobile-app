import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data_models/journal_entry.dart';
import '../data_models/user_model.dart'; // ✅ Pastikan import ini ada

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moodiary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Cek kolom dulu (SQLite agak ribet utk cek kolom, tapi try-catch aman)
          try {
            await db.execute('ALTER TABLE journals ADD COLUMN insight TEXT');
          } catch (e) {
            // Kolom mungkin sudah ada, abaikan
          }
        }
        if (oldVersion < 5) {
          // 👇 GUNAKAN "IF NOT EXISTS" AGAR TIDAK CRASH JIKA TABEL SUDAH ADA
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              pin TEXT,
              avatarEmoji TEXT,
              bio TEXT
            )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        mood TEXT,
        moodScore INTEGER,
        date TEXT,
        insight TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        pin TEXT,
        avatarEmoji TEXT,
        bio TEXT
      )
    ''');
  }

  // ==========================================
  // 📝 BAGIAN JURNAL (JOURNAL ENTRY)
  // ==========================================

  Future<int> insertJournal(JournalEntry entry) async {
    final db = await instance.database;
    return await db.insert(
      'journals',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<JournalEntry>> getAllJournals() async {
    final db = await instance.database;
    final result = await db.query('journals', orderBy: 'date DESC');
    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  Future<String?> getLastMood() async {
    final db = await instance.database;
    final result = await db.query('journals', orderBy: 'date DESC', limit: 1);
    if (result.isNotEmpty) return result.first['mood'] as String;
    return null;
  }

  // ✅ Fungsi ini dikembalikan (fix error update)
  Future<int> updateJournal(JournalEntry entry) async {
    final db = await instance.database;
    return await db.update(
      'journals',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournal(int id) async {
    final db = await instance.database;
    return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllJournals() async {
    final db = await instance.database;
    return await db.delete('journals');
  }

  // ✅ Fungsi ini dikembalikan (fix error filter)
  Future<List<JournalEntry>> getJournalsByMood(String mood) async {
    final db = await instance.database;
    final result = await db.query(
      'journals',
      where: 'mood = ?',
      whereArgs: [mood],
    );
    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  // ✅ Fungsi ini dikembalikan (FIX ERROR trends_screen.dart)
  Future<List<Map<String, dynamic>>> getWeeklyTrends() async {
    final db = await instance.database;
    final result = await db.query(
      'journals',
      columns: ['date', 'moodScore', 'mood'],
      orderBy: 'date DESC',
      limit: 7,
    );
    return result.reversed.toList();
  }

  // ==========================================
  // 👤 BAGIAN USER (AUTH & PROFILE)
  // ==========================================

  // Cek apakah sudah ada user terdaftar?
  Future<bool> isUserRegistered() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.isNotEmpty;
  }

  // Register User Baru
  Future<int> registerUser(User user) async {
    final db = await instance.database;
    // Hapus user lama jika ada (reset), karena aplikasi ini single user
    await db.delete('users');
    return await db.insert('users', user.toMap());
  }

  // Ambil Data User
  Future<User?> getUser() async {
    final db = await instance.database;
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Login (Cek PIN)
  Future<bool> verifyPin(String inputPin) async {
    final user = await getUser();
    if (user != null) {
      return user.pin == inputPin;
    }
    return false;
  }

  // Update Profile
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Clears ALL data from the app (users + journals)
  /// Used for logout or reset functionality
  Future<void> clearAllData() async {
    final db = await instance.database;
    
    // Use transaction to ensure both deletes succeed or fail together
    await db.transaction((txn) async {
      await txn.delete('users');
      await txn.delete('journals');
    });
  }

}
