import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/cities.dart';
import 'screens/azkar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tasbih_screen.dart';
import 'services/notification_service.dart';
import 'services/prayer_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MuazzenApp());
}

/// الجذر — يحمل الإعدادات ويمرّرها للشاشات.
class MuazzenApp extends StatefulWidget {
  const MuazzenApp({super.key});

  @override
  State<MuazzenApp> createState() => _MuazzenAppState();
}

class _MuazzenAppState extends State<MuazzenApp> {
  final _settingsService = SettingsService();
  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _settingsService.load();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loaded = true;
    });
    // إعادة الجدولة عند فتح التطبيق: إن كان المؤذن يعمل وغير مكتوم،
    // نضمن جدولة اليوم والغد (يغطي انتهاء الكتم المؤقت وتغيّر التاريخ).
    // ملاحظة: بعد إعادة تشغيل الجهاز نفسه، الإشعارات المجدولة تُستعاد
    // تلقائياً بواسطة ScheduledNotificationBootReceiver (انظر AndroidManifest)
    // حتى دون فتح التطبيق.
    if (s.alertsActive) {
      final city = arabCities[s.cityIndex.clamp(0, arabCities.length - 1)];
      final now = DateTime.now();
      await NotificationService.instance.enableAll(
        today: PrayerService.forDate(
            lat: city.lat, lng: city.lng, date: now, methodKey: s.methodKey, hanafi: s.hanafi),
        tomorrow: PrayerService.forDate(
            lat: city.lat, lng: city.lng, date: now.add(const Duration(days: 1)), methodKey: s.methodKey, hanafi: s.hanafi),
        enabled: s.prayerNotifications,
        adhanSound: s.adhanSound,
      );
    }
  }

  Future<void> _update(AppSettings s) async {
    setState(() => _settings = s);
    await _settingsService.save(s);
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF0E7A5F);
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: emerald, brightness: Brightness.light),
      fontFamily: 'Roboto',
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: emerald, brightness: Brightness.dark),
      fontFamily: 'Roboto',
    );

    if (!_loaded) {
      return MaterialApp(
        theme: light,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'المؤذن',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: light,
      darkTheme: dark,
      themeMode: _settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      // RTL يُفرض تلقائياً مع اللغة العربية، ونؤكّده صراحة:
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: RootScaffold(settings: _settings, onSettingsChanged: _update),
    );
  }
}

class RootScaffold extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;
  const RootScaffold({super.key, required this.settings, required this.onSettingsChanged});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  // Initial tab can be deep-linked with ?tab=N (used for store screenshots on web).
  int _index = int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    if (_index < 0 || _index > 4) _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final city = arabCities[widget.settings.cityIndex.clamp(0, arabCities.length - 1)];
    final pages = [
      HomeScreen(city: city, settings: widget.settings, onSettingsChanged: widget.onSettingsChanged),
      const AzkarScreen(),
      const TasbihScreen(),
      QiblaScreen(city: city),
      SettingsScreen(settings: widget.settings, onChanged: widget.onSettingsChanged),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque), label: 'الصلاة'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.fingerprint), label: 'السبحة'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'القبلة'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
