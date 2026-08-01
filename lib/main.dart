import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/core.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Force RTL text direction globally.
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
/// - RTL layout via Arabic locale
/// - Light/Dark themes with Islamic aesthetic
/// - Material 3 design system
class ZekrApp extends StatelessWidget {
  const ZekrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ─── Identity ────────────────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ─── Localization & RTL ──────────────────────────────────────────────────
      // Force right-to-left text direction for all languages.
      locale: const Locale('ar'),
      supportedLocales: AppConstants.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Always resolve to Arabic to enforce RTL globally.
        return const Locale('ar');
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Themes ──────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // Force RTL regardless of device locale.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // ─── Home ────────────────────────────────────────────────────────────────
      // Phase 1 placeholder home. Feature navigation will be implemented
      // in upcoming phases (Quran Reader, Sebha, Azkar).
      home: const _HomePlaceholder(),
    );
  }
}

/// Temporary placeholder home screen for Phase 1.
///
/// Will be replaced with the main navigation shell in a future phase.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appNameArabic),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Islamic geometric ornament placeholder symbol
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 3),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'مرحباً بك في تطبيق ذكر',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'البنية الأساسية جاهزة ✅',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}