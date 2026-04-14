part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String languageCode;
  final bool isDarkMode;

  const SettingsState({
    this.languageCode = 'bn',
    this.isDarkMode = true,
  });

  SettingsState copyWith({
    String? languageCode,
    bool? isDarkMode,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [languageCode, isDarkMode];
}