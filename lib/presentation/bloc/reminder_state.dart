part of 'reminder_bloc.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;

  const ReminderLoaded(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class ReminderAdded extends ReminderState {
  final List<Reminder> reminders;
  final String title;

  const ReminderAdded(this.reminders, this.title);

  @override
  List<Object?> get props => [reminders, title];
}

class ReminderDeleted extends ReminderState {
  final List<Reminder> reminders;

  const ReminderDeleted(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class ReminderParsed extends ReminderState {
  final ParsedReminder? parsed;

  const ReminderParsed(this.parsed);

  @override
  List<Object?> get props => [parsed];
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);

  @override
  List<Object?> get props => [message];
}