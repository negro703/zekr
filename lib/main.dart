import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/core.dart';
import 'features/home/home.dart';
import 'features/settings/settings.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize local services (Hive, SharedPreferences, Notifications).
  try {
    await LocalStorageService.instance.init();
  } catch (e) {
    // Log storage initialization failure; app can still start in memory-only mode.
    debugPrint('LocalStorage initialization failed: $e');
  }

  try {
    await LocalNotificationService.instance.init();
  } catch (e) {
    // Notification failures should not block app startup.
    debugPrint('Notification initialization failed: $e');
  }

  runApp(const ZekrApp());
}

/// Root widget of the Zekr application.
///
/// Configures:
/// - Dynamic locale (Arabic/English) + RTL/LTR layout via [AppSettingsCubit]
/// - Light/Dark/System theme control via [AppSettingsCubit]
/// - Material 3 design system
/// - Home navigation shell (Quran, Azkar, Sebha, Settings)
class ZekrApp extends StatelessWidget {
  const ZekrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppSettingsCubit()..loadSettings(),
      child: const _ZekrMaterialApp(),
    );
  }
}

class _ZekrMaterialApp extends StatelessWidget {
  const _ZekrMaterialApp();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
      buildWhen: (prev, cur) =>
          prev.language != cur.language || prev.themeMode != cur.themeMode,
      builder: (context, settings) {
        final locale = settings.language.locale;
        final isRtl = locale.languageCode == 'ar';

        return MaterialApp(
          // ─── Identity ──────────────────────────────────────────────────────
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // ─── Localization & Direction ─────────────────────────────────────
          locale: locale,
          supportedLocales: AppStringsDelegate.supportedLocales,
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ─── Themes (manual user control) ─────────────────────────────────
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode.mode,

          // Force layout direction based on the active locale.
          builder: (context, child) {
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },

          // ─── Home: Navigation Shell ────────────────────────────────────────
          home: const HomePage(),
        );
      },
    );
  }
}