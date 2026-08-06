import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';

/// Settings page for managing notification reminders.
///
/// Allows the user to:
/// - Toggle Morning Azkar reminder (with time picker)
/// - Toggle Evening Azkar reminder (with time picker)
/// - Toggle periodic Salawat reminders (with a flexible minutes-based
///   interval selector)
///
/// Preferences are loaded synchronously from local storage on first
/// mount so the settings UI renders instantly with zero hanging spinners.
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Kick off the synchronous preference load on the first frame so the
    // cubit transitions out of NotificationsInitial immediately.
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
        title: const Text('إعدادات التذكيرات'),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        buildWhen: (prev, cur) =>
            cur is NotificationsLoading ||
            cur is NotificationsLoaded ||
            cur is NotificationsError,
        builder: (context, state) {
          switch (state) {
            case NotificationsInitial():
            case NotificationsLoading():
              return const _SettingsLoading();
            case NotificationsError(:final message):
              return _SettingsError(
                message: message,
                onRetry: context.read<NotificationsCubit>().loadPreferences,
              );
            case NotificationsLoaded(:final preferences):
              return _SettingsList(preferences: preferences);
          }
        },
      ),
    );
  }
}

/// Scrollable list of notification settings.
class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.preferences});

  final NotificationPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─── Morning Azkar ─────────────────────────────────────────────────────
        _SectionHeader(
          title: 'أذكار الصباح',
          icon: Icons.wb_sunny_outlined,
          color: AppColors.gold,
        ),
        SwitchListTile(
          title: const Text('تفعيل تذكير أذكار الصباح'),
          subtitle: Text(
            'تذكير يومي في ${_formatTime(preferences.morningHour, preferences.morningMinute)}',
          ),
          value: preferences.morningEnabled,
          activeTrackColor: primaryColor,
          onChanged: cubit.setMorningEnabled,
        ),
        ListTile(
          enabled: preferences.morningEnabled,
          leading: const Icon(Icons.access_time),
          title: const Text('وقت التذكير'),
          subtitle: Text(
            _formatTime(preferences.morningHour, preferences.morningMinute),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => _pickTime(
            context,
            preferences.morningHour,
            preferences.morningMinute,
            (h, m) => cubit.setMorningTime(h, m),
          ),
        ),
        const Divider(),

        // ─── Evening Azkar ─────────────────────────────────────────────────────
        _SectionHeader(
          title: 'أذكار المساء',
          icon: Icons.nights_stay_outlined,
          color: AppColors.info,
        ),
        SwitchListTile(
          title: const Text('تفعيل تذكير أذكار المساء'),
          subtitle: Text(
            'تذكير يومي في ${_formatTime(preferences.eveningHour, preferences.eveningMinute)}',
          ),
          value: preferences.eveningEnabled,
          activeTrackColor: primaryColor,
          onChanged: cubit.setEveningEnabled,
        ),
        ListTile(
          enabled: preferences.eveningEnabled,
          leading: const Icon(Icons.access_time),
          title: const Text('وقت التذكير'),
          subtitle: Text(
            _formatTime(preferences.eveningHour, preferences.eveningMinute),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => _pickTime(
            context,
            preferences.eveningHour,
            preferences.eveningMinute,
            (h, m) => cubit.setEveningTime(h, m),
          ),
        ),
        const Divider(),

        // ─── Salawat (Prayers on the Prophet) ──────────────────────────────────
        _SectionHeader(
          title: 'الصلاة على النبي ﷺ',
          icon: Icons.favorite_outline,
          color: AppColors.emerald,
        ),
        SwitchListTile(
          title: const Text('تفعيل التذكير الدوري'),
          subtitle: const Text('تذكير متكرر للصلاة على النبي ﷺ'),
          value: preferences.salawatEnabled,
          activeTrackColor: primaryColor,
          onChanged: cubit.setSalawatEnabled,
        ),
        ListTile(
          enabled: preferences.salawatEnabled,
          leading: const Icon(Icons.timer_outlined),
          title: const Text('الفاصل الزمني'),
          subtitle: Text(
            _formatInterval(preferences.salawatIntervalMinutes),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => _pickInterval(
            context,
            cubit,
            preferences.salawatIntervalMinutes,
          ),
        ),
      ],
    );
  }

  /// Shows a time picker and applies the result.
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

  /// Shows a scrollable, flexible interval selector for Salawat reminders.
  ///
  /// The sheet is wrapped in a [SingleChildScrollView] inside a
  /// [SafeArea] so it can never overflow on any screen size. It offers
  /// both quick presets and a free-form minutes input for an exact
  /// custom interval.
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

  /// Formats a minutes value as a human-friendly Arabic label.
  String _formatInterval(int minutes) {
    if (minutes < 60) {
      return 'كل ${_toArabicDigits(minutes)} دقيقة';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return 'كل ${_toArabicDigits(hours)} ساعة';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return 'كل ${_toArabicDigits(hours)} ساعة و ${_toArabicDigits(mins)} دقيقة';
  }

  String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }
}

/// A scrollable bottom-sheet for choosing the Salawat interval.
///
/// Provides quick presets plus a free-form minutes field so the user can
/// set an exact custom interval (e.g. 15, 30, 45, 90 minutes).
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

  /// Quick presets in minutes.
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
    if (parsed == null ||
        parsed < AppConstants.minSalawatIntervalMinutes ||
        parsed > AppConstants.maxSalawatIntervalMinutes) {
      setState(() {
        _errorText =
            'أدخل قيمة بين ${AppConstants.minSalawatIntervalMinutes} و ${AppConstants.maxSalawatIntervalMinutes} دقيقة';
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

    return Padding(
      // Add bottom padding equal to the keyboard inset so the input field
      // shifts up and remains fully visible above the keyboard.
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
                'الفاصل الزمني',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'اختر فاصل زمني للصلاة على النبي ﷺ',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // ─── Quick Presets ─────────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _presets.map((minutes) {
                  final isSelected = minutes == widget.currentMinutes;
                  return ChoiceChip(
                    label: Text(_presetLabel(minutes)),
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

              // ─── Custom Minutes Input ──────────────────────────────────────
              Text(
                'فاصل مخصص بالدقائق',
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
                  hintText: 'مثال: 25',
                  suffixText: 'دقيقة',
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
                label: const Text('تطبيق الفاصل المخصص'),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _presetLabel(int minutes) {
    if (minutes < 60) return '${_toArabicDigits(minutes)} د';
    if (minutes % 60 == 0) {
      return '${_toArabicDigits(minutes ~/ 60)} س';
    }
    return '${_toArabicDigits(minutes ~/ 60)}س ${_toArabicDigits(minutes % 60)}د';
  }

  String _toArabicDigits(int value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((c) {
      final d = int.parse(c);
      return arabic[d];
    }).join();
  }
}

/// Section header with icon and title.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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

/// Loading view.
class _SettingsLoading extends StatelessWidget {
  const _SettingsLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.emeraldLight : AppColors.emerald;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: accent),
          const SizedBox(height: 16),
          Text('جاري تحميل الإعدادات...',
              style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Error view.
class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.emeraldLight : AppColors.emerald;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(backgroundColor: accent),
            ),
          ],
        ),
      ),
    );
  }
}