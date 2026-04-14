import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/reminder_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../../data/models/reminder_model.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _commandController = TextEditingController();
  late ReminderParser? _parsed;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF07101B),
              const Color(0xFF0F1F34),
              const Color(0xFF0A1424),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  settings.languageCode == 'bn' ? 'মনে রাখো' : 'Remind Me',
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      context.read<SettingsCubit>().toggleLanguage();
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(context, l10n, settings.languageCode),
                      const SizedBox(height: 20),
                      _buildReminderList(context, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppLocalizations l10n, String langCode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF6ED6FF),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commandController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: langCode == 'bn'
                    ? 'যেমন: আমাকে 5 মিনিট পর মিটিং এ join করার কথা মনে করাইবা'
                    : 'e.g. Remind me in 5 minutes to join meeting',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<ReminderBloc>().add(ParseCommand(value));
                }
              },
            ),
            const SizedBox(height: 16),
            _buildQuickChips(context, langCode),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSetReminder,
                    child: Text(l10n.setReminder),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _requestNotificationPermission,
                  child: Text(l10n.enableNotification),
                ),
              ],
            ),
            BlocListener<ReminderBloc, ReminderState>(
              listener: (context, state) {
                if (state is ReminderAdded) {
                  _commandController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(langCode == 'bn'
                          ? 'Reminder set হয়েছে!'
                          : 'Reminder set!'),
                      backgroundColor: const Color(0xFF0E1B2D),
                    ),
                  );
                } else if (state is ReminderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red.shade900,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChips(BuildContext context, String langCode) {
    final examples = langCode == 'bn'
        ? [
            'আমাকে ৫ মিনিট পর বাজারে যাওয়ার কথা মনে করাইবা',
            'আমাকে 10:10 এ পানি খেতে বলবা',
            'রাত ৯টায় ঘুমানোর কথা মনে করাইবা',
          ]
        : [
            'Remind me in 5 minutes to go to market',
            'Remind me to drink water at 10:10',
            'Remind me at 9pm to sleep',
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: examples.map((example) {
        return ActionChip(
          label: Text(
            example.length > 25 ? '${example.substring(0, 25)}...' : example,
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            _commandController.text = example;
            context.read<ReminderBloc>().add(ParseCommand(example));
          },
          backgroundColor: const Color(0xFF6ED6FF).withOpacity(0.1),
        );
      }).toList(),
    );
  }

  Widget _buildReminderList(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final reminders = state is ReminderLoaded
            ? state.reminders
            : state is ReminderAdded
                ? state.reminders
                : state is ReminderDeleted
                    ? state.reminders
                    : <Reminder>[];

        if (reminders.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  l10n.noReminders,
                  style: const TextStyle(color: Color(0xFF9FB6CA)),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                '${reminders.length} ${l10n.active}',
                style: const TextStyle(
                  color: Color(0xFF9FB6CA),
                  fontSize: 13,
                ),
              ),
            ),
            ...reminders.map((reminder) => _buildReminderCard(context, reminder)),
          ],
        );
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          reminder.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            dateFormat.format(reminder.remindAt),
            style: const TextStyle(color: Color(0xFF9FB6CA)),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
          onPressed: () {
            context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
          },
        ),
      ),
    );
  }

  void _onSetReminder() {
    if (_commandController.text.trim().isNotEmpty) {
      context.read<ReminderBloc>().add(AddReminder(_commandController.text.trim()));
    }
  }

  Future<void> _requestNotificationPermission() async {
    // Handled by notification service automatically
  }
}

class ReminderParser {
  final String title;
  final DateTime remindAt;

  ReminderParser({required this.title, required this.remindAt});
}