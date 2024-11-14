import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note_model.dart';

class DatabaseHelper {
  static const _databaseName = 'notes.db';
  static const _databaseVersion = 2;  // Збільшуємо версію бази даних для міграції
  static const table = 'notes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    // Отримуємо шлях до бази даних
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) {
        // При першому створенні бази даних створюємо таблицю
        return db.execute(
          'CREATE TABLE $table(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Видаляємо таблицю при оновленні версії бази даних
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS $table');
          // Створюємо нову таблицю
          await db.execute(
            'CREATE TABLE $table(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date TEXT)',
          );
        }
      },
      version: _databaseVersion,  // Оновлена версія бази даних
    );
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      table,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
}
