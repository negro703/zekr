import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/notifications.dart';
import '../bloc/app_settings_cubit.dart';
import '../bloc/app_settings_state.dart';

/// The main Settings page for the Zekr app.
///
/// Sections:
/// - **اللغة / Language**: switch between Arabic and English
/// - **المظهر / Theme**: System Default / Light / Dark
/// - **التذكيرات / Reminders**: notification preferences (morning/evening
///   Azkar, Salawat)
///
/// All choices are persisted via [AppSettingsCubit] (language & theme)
/// and [NotificationsCubit] (reminders) using SharedPreferences.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Kick off the notification preference load so the notifications
    // section transitions out of its initial state immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationsCubit>();
      if (cubit.state is NotificationsInitial) {
        cubit.loadPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AppSettingsCubit, AppSettings>(
          buildWhen: (prev, cur) => prev.language != cur.language,
          builder: (context, _) => Text(AppStrings.of(context).settingsTitle),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        buildWhen: (prev, cur) =>
            cur is NotificationsLoading ||
            cur is NotificationsLoaded ||
            cur is NotificationsError,
        builder: (context, notificationsState) {
          return BlocBuilder<AppSettingsCubit, AppSettings>(
            builder: (context, settings) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── Language Section ───────────────────────────────────────
                  _SettingsSectionHeader(
                    title: AppStrings.of(context).sectionLanguage,
                    icon: Icons.language,
                    color: AppColors.gold,
                  ),
                  _SettingsTile(
                    icon: Icons.translate,
                    title: AppStrings.of(context).languageLabel,
                    subtitle: settings.language == AppLanguage.english
                        ? AppStrings.of(context).english
                        : AppStrings.of(context).arabic,
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ─── Theme Section ─────────────────────────────────────────
                  _SettingsSectionHeader(
                    title: AppStrings.of(context).sectionTheme,
                    icon: Icons.dark_mode_outlined,
                    color: AppColors.emerald,
                  ),
                  _SettingsTile(
                    icon: _themeIcon(settings.themeMode),
                    title: AppStrings.of(context).themeDialogTitle,
                    subtitle: _themeLabel(context, settings.themeMode),
                    onTap: () => _showThemeDialog(context),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ─── Notifications Section ─────────────────────────────────
                  _SettingsSectionHeader(
                    title: AppStrings.of(context).sectionNotifications,
                    icon: Icons.notifications_outlined,
                    color: AppColors.info,
                  ),
                  ..._buildNotificationsSection(context, notificationsState),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ─── Language Dialog ─────────────────────────────────────────────────────

  Future<void> _showLanguageDialog(BuildContext context) async {
    final settingsCubit = context.read<AppSettingsCubit>();
    final strings = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.of(ctx).languageDialogTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              subtitle: const Text('اللغة الافتراضية'),
              trailing: settingsCubit.state.language == AppLanguage.arabic
                  ? Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(AppLanguage.arabic),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              subtitle: const Text('Default language'),
              trailing: settingsCubit.state.language == AppLanguage.english
                  ? Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(AppLanguage.english),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await settingsCubit.setLanguage(selected);
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(strings.languageChanged)),
          );
      }
    }
  }

  // ─── Theme Dialog ────────────────────────────────────────────────────────

  Future<void> _showThemeDialog(BuildContext context) async {
    final settingsCubit = context.read<AppSettingsCubit>();
    final strings = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final selected = await showModalBottomSheet<AppThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.of(ctx).themeDialogTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            for (final mode in AppThemeMode.values)
              ListTile(
                leading: Icon(_themeIcon(mode)),
                title: Text(_themeLabel(ctx, mode)),
                trailing: settingsCubit.state.themeMode == mode
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      await settingsCubit.setThemeMode(selected);
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(strings.themeChanged)),
          );
      }
    }
  }

  // ─── Notifications Section Builder ───────────────────────────────────────

  List<Widget> _buildNotificationsSection(
    BuildContext context,
    NotificationsState state,
  ) {
    final notificationsCubit = context.read<NotificationsCubit>();
    final strings = AppStrings.of(context);
    final settings = context.read<AppSettingsCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    switch (state) {
      case NotificationsInitial():
      case NotificationsLoading():
        return [
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];

      case NotificationsError(:final message):
        return [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: notificationsCubit.loadPreferences,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.retry),
                ),
              ],
            ),
          ),
        ];

      case NotificationsLoaded(:final preferences):
        return [
          SwitchListTile(
            title: Text(strings.mushafDarkBackground),
            subtitle: Text(strings.mushafDarkBackgroundDescription),
            value: settings.mushafDarkBackground,
            activeTrackColor: primaryColor,
            onChanged: (value) =>
                context.read<AppSettingsCubit>().setMushafDarkBackground(value),
          ),
          const Divider(),
          _NotificationSwitchTile(
            title: strings.morningAzkarEnabled,
            subtitle: strings.morningReminderAt(
              preferences.morningHour,
              preferences.morningMinute,
            ),
            value: preferences.morningEnabled,
            activeColor: primaryColor,
            onChanged: notificationsCubit.setMorningEnabled,
          ),
          ListTile(
            enabled: preferences.morningEnabled,
            leading: const Icon(Icons.access_time),
            title: Text(strings.reminderTime),
            subtitle: Text(
              _formatTime(preferences.morningHour, preferences.morningMinute),
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => _pickTime(
              context,
              preferences.morningHour,
              preferences.morningMinute,
              (h, m) => notificationsCubit.setMorningTime(h, m),
            ),
          ),
          const Divider(),

          SwitchListTile(
            title: Text(strings.eveningAzkarEnabled),
            subtitle: Text(strings.eveningReminderAt(
              preferences.eveningHour,
              preferences.eveningMinute,
            )),
            value: preferences.eveningEnabled,
            activeTrackColor: primaryColor,
            onChanged: notificationsCubit.setEveningEnabled,
          ),
          ListTile(
            enabled: preferences.eveningEnabled,
            leading: const Icon(Icons.access_time),
            title: Text(strings.reminderTime),
            subtitle: Text(
              _formatTime(preferences.eveningHour, preferences.eveningMinute),
            ),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => _pickTime(
              context,
              preferences.eveningHour,
              preferences.eveningMinute,
              (h, m) => notificationsCubit.setEveningTime(h, m),
            ),
          ),
          const Divider(),

          SwitchListTile(
            title: Text(strings.salawatEnabled),
            subtitle: Text(strings.chooseInterval),
            value: preferences.salawatEnabled,
            activeTrackColor: primaryColor,
            onChanged: notificationsCubit.setSalawatEnabled,
          ),
          ListTile(
            enabled: preferences.salawatEnabled,
            leading: const Icon(Icons.timer_outlined),
            title: Text(strings.intervalTitle),
            subtitle: Text(strings.intervalSubtitle(
              preferences.salawatIntervalMinutes,
            )),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => _pickInterval(
              context,
              notificationsCubit,
              preferences.salawatIntervalMinutes,
            ),
          ),
        ];
    }
  }

  // ─── Dialogs & Helpers ───────────────────────────────────────────────────

  Future<void> _pickTime(
    BuildContext context,
    int hour,
    int minute,
    void Function(int, int) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) {
      onPicked(picked.hour, picked.minute);
    }
  }

  Future<void> _pickInterval(
    BuildContext context,
    NotificationsCubit cubit,
    int currentMinutes,
  ) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _IntervalPickerSheet(
        currentMinutes: currentMinutes,
        onSelected: (minutes) => Navigator.of(ctx).pop(minutes),
      ),
    );
    if (selected != null) {
      cubit.setSalawatInterval(selected);
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  IconData _themeIcon(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => Icons.brightness_auto,
      AppThemeMode.light => Icons.light_mode_outlined,
      AppThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  String _themeLabel(BuildContext context, AppThemeMode mode) {
    final strings = AppStrings.of(context);
    return switch (mode) {
      AppThemeMode.system => strings.systemDefault,
      AppThemeMode.light => strings.lightMode,
      AppThemeMode.dark => strings.darkMode,
    };
  }
}

/// Section header with icon and colored title.
class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Standard settings list tile with leading icon, title, subtitle, and chevron.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_left,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// A localized switch list tile for notification reminders.
class _NotificationSwitchTile extends StatelessWidget {
  const _NotificationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeTrackColor: activeColor,
      onChanged: onChanged,
    );
  }
}

/// A scrollable bottom-sheet for choosing the Salawat interval.
class _IntervalPickerSheet extends StatefulWidget {
  const _IntervalPickerSheet({
    required this.currentMinutes,
    required this.onSelected,
  });

  final int currentMinutes;
  final ValueChanged<int> onSelected;

  @override
  State<_IntervalPickerSheet> createState() => _IntervalPickerSheetState();
}

class _IntervalPickerSheetState extends State<_IntervalPickerSheet> {
  late final TextEditingController _minutesController;
  String? _errorText;

  static const List<int> _presets = [1, 5, 10, 15, 30, 45, 60, 90, 120, 180, 240];

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.currentMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _submitCustom() {
    final raw = _minutesController.text.trim();
    final parsed = int.tryParse(raw);
    final strings = AppStrings.of(context);

    if (parsed == null ||
        parsed < AppConstants.minSalawatIntervalMinutes ||
        parsed > AppConstants.maxSalawatIntervalMinutes) {
      setState(() {
        _errorText = strings.errorIntervalRange(
          AppConstants.minSalawatIntervalMinutes,
          AppConstants.maxSalawatIntervalMinutes,
        );
      });
      return;
    }
    widget.onSelected(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;
    final strings = AppStrings.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.intervalTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                strings.chooseInterval,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _presets.map((minutes) {
                  final isSelected = minutes == widget.currentMinutes;
                  return ChoiceChip(
                    label: Text(_presetLabel(strings, minutes)),
                    selected: isSelected,
                    selectedColor: primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : null,
                      fontWeight: isSelected ? FontWeight.w700 : null,
                    ),
                    onSelected: (_) => widget.onSelected(minutes),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Text(
                strings.customInterval,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: strings.customIntervalHint,
                  suffixText: strings.minutesUnit,
                  errorText: _errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _submitCustom(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _submitCustom,
                icon: const Icon(Icons.check),
                label: Text(strings.applyCustomInterval),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _presetLabel(AppStrings strings, int minutes) {
    if (minutes < 60) return strings.everyMinuteAbbrev(minutes);
    if (minutes % 60 == 0) {
      return strings.everyHourAbbrev(minutes ~/ 60);
    }
    return strings.everyHourMinuteAbbrev(minutes ~/ 60, minutes % 60);
  }
}