import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'presentation/bloc/reminder_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await NotificationService.initialize();
  await AlarmService.initialize();
  
  runApp(
    BlocProvider(
      create: (_) => ReminderBloc()..add(LoadReminders()),
      child: const RemindMeApp(),
    ),
  );
}