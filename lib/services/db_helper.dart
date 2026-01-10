import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper instance = DbHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pokemon_diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            content TEXT,
            sentiment TEXT,
            pokemon_id INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertDiary(Diary diary) async {
    final db = await database;
    return db.insert('diaries', diary.toMap());
  }

  Future<List<Diary>> getDiaries() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map((map) => Diary.fromMap(map)).toList();
  }

  Future<int> deleteDiary(int id) async {
    final db = await database;
    return db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> seedMockData() async {
    final db = await database;
    final existing = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM diaries'),
    );

    if (existing != null && existing > 0) return;

    final today = DateTime.now();
    final mockEntries = <Diary>[
      Diary(
        date: _formatDate(today),
        content: 'Had a great day exploring new places!',
        sentiment: 'joy',
        pokemonId: 25,
      ),
      Diary(
        date: _formatDate(today.subtract(const Duration(days: 1))),
        content: 'Feeling a bit down and tired today.',
        sentiment: 'sad',
        pokemonId: 92,
      ),
      Diary(
        date: _formatDate(today.subtract(const Duration(days: 2))),
        content: 'Got frustrated with some chores, but it passed.',
        sentiment: 'angry',
        pokemonId: 4,
      ),
      Diary(
        date: _formatDate(today.subtract(const Duration(days: 3))),
        content: 'Quiet and peaceful day, just relaxing.',
        sentiment: 'calm',
        pokemonId: 1,
      ),
    ];

    for (final entry in mockEntries) {
      await db.insert('diaries', entry.toMap());
    }
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}