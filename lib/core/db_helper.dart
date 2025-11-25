import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data_models/journal_entry.dart';

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
      version: 4, // ⬅️ versi diperbarui
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // tambahkan kolom insight jika upgrade dari versi lama
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE journals ADD COLUMN insight TEXT');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        mood TEXT,
        moodScore INTEGER,
        date TEXT,
        insight TEXT
      )
    ''');
  }

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

  Future<List<JournalEntry>> getJournalsByMood(String mood) async {
    final db = await instance.database;
    final result = await db.query(
      'journals',
      where: 'mood = ?',
      whereArgs: [mood],
    );
    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getWeeklyTrends() async {
    final db = await instance.database;
    // Ambil 7 data terakhir, urutkan dari yang terlama ke terbaru untuk grafik
    final result = await db.query(
      'journals',
      columns: ['date', 'moodScore', 'mood'],
      orderBy: 'date DESC', // Ambil terbaru dulu
      limit: 7,
    );
    return result.reversed
        .toList(); // Balik urutan agar di grafik dari kiri (lama) ke kanan (baru)
  }

  // 👇 Tambahkan ini
  Future<int> deleteAllJournals() async {
    final db = await instance.database;
    return await db.delete('journals');
  }
}
