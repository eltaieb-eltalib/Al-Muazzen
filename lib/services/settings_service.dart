import 'package:shared_preferences/shared_preferences.dart';

/// إعدادات التطبيق المحفوظة محلياً — بدون أي خادم أو تتبّع.
class AppSettings {
  final int cityIndex;
  final bool useGps;
  final String methodKey;
  final bool hanafi;
  final bool darkMode;
  final Map<String, bool> prayerNotifications;

  /// المفتاح الرئيسي: المؤذن يعمل / متوقف كلياً.
  /// OFF = لا إشعارات مجدولة ولا صوت أذان. يُحفظ ويُستعاد عند فتح التطبيق.
  final bool masterEnabled;

  /// كتم مؤقت حتى هذا الوقت (null = غير مكتوم).
  final DateTime? mutedUntil;

  /// تشغيل صوت الأذان كاملاً عند دخول وقت الصلاة.
  /// false = تنبيه بصوت إشعارات الجهاز الافتراضي فقط.
  final bool adhanSound;

  const AppSettings({
    this.cityIndex = 0,
    this.useGps = false,
    this.methodKey = 'muslim_world_league',
    this.hanafi = false,
    this.darkMode = false,
    this.masterEnabled = true,
    this.mutedUntil,
    this.adhanSound = true,
    this.prayerNotifications = const {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
  });

  /// هل الكتم المؤقت ما زال سارياً الآن؟
  bool get isMuted => mutedUntil != null && mutedUntil!.isAfter(DateTime.now());

  /// هل التنبيهات فعّالة فعلياً؟ (المفتاح الرئيسي يعمل + غير مكتوم)
  bool get alertsActive => masterEnabled && !isMuted;

  AppSettings copyWith({
    int? cityIndex,
    bool? useGps,
    String? methodKey,
    bool? hanafi,
    bool? darkMode,
    bool? masterEnabled,
    DateTime? mutedUntil,
    bool? adhanSound,
    bool clearMutedUntil = false,
    Map<String, bool>? prayerNotifications,
  }) {
    return AppSettings(
      cityIndex: cityIndex ?? this.cityIndex,
      useGps: useGps ?? this.useGps,
      methodKey: methodKey ?? this.methodKey,
      hanafi: hanafi ?? this.hanafi,
      darkMode: darkMode ?? this.darkMode,
      masterEnabled: masterEnabled ?? this.masterEnabled,
      adhanSound: adhanSound ?? this.adhanSound,
      mutedUntil: clearMutedUntil ? null : (mutedUntil ?? this.mutedUntil),
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
    );
  }
}

class SettingsService {
  static const _kCity = 'city_index';
  static const _kGps = 'use_gps';
  static const _kMethod = 'method_key';
  static const _kHanafi = 'hanafi';
  static const _kDark = 'dark_mode';
  static const _kMaster = 'master_enabled';
  static const _kAdhanSound = 'adhan_sound';
  static const _kMutedUntil = 'muted_until_iso';
  static const _kNotifPrefix = 'notif_';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final notifs = <String, bool>{};
    for (final k in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      notifs[k] = prefs.getBool('$_kNotifPrefix$k') ?? true;
    }
    final mutedRaw = prefs.getString(_kMutedUntil);
    return AppSettings(
      cityIndex: prefs.getInt(_kCity) ?? 0,
      useGps: prefs.getBool(_kGps) ?? false,
      methodKey: prefs.getString(_kMethod) ?? 'muslim_world_league',
      hanafi: prefs.getBool(_kHanafi) ?? false,
      darkMode: prefs.getBool(_kDark) ?? false,
      masterEnabled: prefs.getBool(_kMaster) ?? true,
      adhanSound: prefs.getBool(_kAdhanSound) ?? true,
      mutedUntil: mutedRaw == null ? null : DateTime.tryParse(mutedRaw),
      prayerNotifications: notifs,
    );
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCity, s.cityIndex);
    await prefs.setBool(_kGps, s.useGps);
    await prefs.setString(_kMethod, s.methodKey);
    await prefs.setBool(_kHanafi, s.hanafi);
    await prefs.setBool(_kDark, s.darkMode);
    await prefs.setBool(_kMaster, s.masterEnabled);
    await prefs.setBool(_kAdhanSound, s.adhanSound);
    if (s.mutedUntil == null) {
      await prefs.remove(_kMutedUntil);
    } else {
      await prefs.setString(_kMutedUntil, s.mutedUntil!.toIso8601String());
    }
    for (final e in s.prayerNotifications.entries) {
      await prefs.setBool('$_kNotifPrefix${e.key}', e.value);
    }
  }
}
