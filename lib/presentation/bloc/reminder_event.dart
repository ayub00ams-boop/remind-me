part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final String command;

  const AddReminder(this.command);

  @override
  List<Object?> get props => [command];
}

class DeleteReminder extends ReminderEvent {
  final String id;

  const DeleteReminder(this.id);

  @override
  List<Object?> get props => [id];
}

class ParseCommand extends ReminderEvent {
  final String command;

  const ParseCommand(this.command);

  @override
  List<Object?> get props => [command];
}

class ClearParsedReminder extends ReminderEvent {}