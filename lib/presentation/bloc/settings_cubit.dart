import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'settings.db');
      final db = await DatabaseFactory.instance.openDatabase(path);
      
      final result = await db.query('settings', where: 'id = ?', whereArgs: [1]);
      
      if (result.isNotEmpty) {
        emit(SettingsState(
          languageCode: result.first['language'] as String? ?? 'bn',
          isDarkMode: (result.first['darkMode'] as int?) == 1,
        ));
      } else {
        await db.insert('settings', {'id': 1, 'language': 'bn', 'darkMode': 1});
      }
    } catch (_) {
      emit(const SettingsState(languageCode: 'bn', isDarkMode: true));
    }
  }

  Future<void> toggleLanguage() async {
    final newLang = state.languageCode == 'bn' ? 'en' : 'bn';
    emit(state.copyWith(languageCode: newLang));
    await _saveSettings();
  }

  Future<void> toggleTheme() async {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'settings.db');
      final db = await DatabaseFactory.instance.openDatabase(path);
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings(
          id INTEGER PRIMARY KEY,
          language TEXT,
          darkMode INTEGER
        )
      ''');
      
      await db.update(
        'settings',
        {
          'language': state.languageCode,
          'darkMode': state.isDarkMode ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [1],
      );
    } catch (_) {}
  }
}