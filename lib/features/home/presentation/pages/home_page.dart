import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/services/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../azkar/azkar.dart';
import '../../../notifications/notifications.dart';
import '../../../quran/quran.dart';
import '../../../sebha/sebha.dart';
import '../../../settings/settings.dart';

/// Main navigation shell for the Zekr app.
///
/// Provides a bottom navigation bar to switch between:
/// - القرآن / Quran Reader
/// - الأذكار / Azkar
/// - السبحة / Sebha
/// - الإعدادات / Settings
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Quran Reader
      BlocProvider(
        create: (_) => QuranCubit(repository: QuranRepositoryImpl()),
        child: const QuranReaderPage(),
      ),
      // Azkar
      BlocProvider(
        create: (_) => AzkarCubit(repository: const AzkarRepositoryImpl()),
        child: const AzkarCategoriesPage(),
      ),
      // Sebha
      BlocProvider(
        create: (_) => SebhaCubit(
          repository: SebhaRepositoryImpl(storage: LocalStorageService.instance),
        ),
        child: const SebhaPage(),
      ),
      // Settings (language, theme, reminders)
      BlocProvider(
        create: (_) => NotificationsCubit(),
        child: const SettingsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.emeraldLight : AppColors.emerald;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<AppSettingsCubit, AppSettings>(
        buildWhen: (prev, cur) => prev.language != cur.language,
        builder: (context, settings) {
          final strings = AppStrings.of(context);
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book, color: primaryColor),
                label: strings.navQuran,
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome, color: primaryColor),
                label: strings.navAzkar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.touch_app_outlined),
                selectedIcon: Icon(Icons.touch_app, color: primaryColor),
                label: strings.navSebha,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: primaryColor),
                label: strings.navSettings,
              ),
            ],
          );
        },
      ),
    );
  }
}