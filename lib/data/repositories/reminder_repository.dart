import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../core/constants/app_constants.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        remindAt TEXT NOT NULL,
        kind TEXT NOT NULL,
        minutes INTEGER,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final maps = await db.query('reminders', orderBy: 'remindAt ASC');
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getActiveReminders() async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'remindAt ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deactivateReminder(String id) async {
    final db = await database;
    await db.update(
      'reminders',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cleanExpiredReminders() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'reminders',
      where: 'remindAt < ? AND isActive = 1',
      whereArgs: [now],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}