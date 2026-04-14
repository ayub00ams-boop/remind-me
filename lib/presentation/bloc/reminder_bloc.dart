import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../services/alarm_service.dart';
import '../../services/notification_service.dart';
import '../../core/utils/bangla_parser.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository = ReminderRepository();

  ReminderBloc() : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<ParseCommand>(_onParseCommand);
    on<ClearParsedReminder>(_onClearParsedReminder);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      await _repository.cleanExpiredReminders();
      final reminders = await _repository.getActiveReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final parsed = BanglaParser.parse(event.command);
      if (parsed == null) {
        emit(const ReminderError('Could not understand command. Try: "৫ মিনিট পর" or "১০:১০ এ"'));
        return;
      }

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: parsed.title,
        remindAt: parsed.remindAt,
        kind: parsed.type == ReminderType.relative
            ? ReminderKind.relative
            : ReminderKind.absolute,
        minutes: parsed.minutes,
        createdAt: DateTime.now(),
      );

      await _repository.insertReminder(reminder);
      await NotificationService.scheduleNotification(reminder);
      await AlarmService.scheduleAlarm(reminder);

      final reminders = await _repository.getActiveReminders();
      emit(ReminderAdded(reminders, reminder.title));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.deactivateReminder(event.id);
      await NotificationService.cancelNotification(event.id);
      await AlarmService.cancelAlarm(event.id);

      final reminders = await _repository.getActiveReminders();
      emit(ReminderDeleted(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onParseCommand(
    ParseCommand event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final parsed = BanglaParser.parse(event.command);
      if (parsed == null) {
        emit(const ReminderParsed(null));
        return;
      }
      emit(ReminderParsed(parsed));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  void _onClearParsedReminder(
    ClearParsedReminder event,
    Emitter<ReminderState> emit,
  ) {
    emit(const ReminderParsed(null));
  }
}