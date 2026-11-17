import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/cities.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../widgets/master_switch.dart';
import 'privacy_screen.dart';

/// الإعدادات: المدينة، طريقة الحساب، المذهب، الإشعارات، المظهر.
class SettingsScreen extends StatelessWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;
  const SettingsScreen({super.key, required this.settings, required this.onChanged});

  static const _prayerNames = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  Future<void> _requestGps(BuildContext context) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يُمنح إذن الموقع — سيتم استخدام المدينة المختارة يدوياً')),
        );
      }
      onChanged(settings.copyWith(useGps: false));
    } else {
      onChanged(settings.copyWith(useGps: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== المفتاح الرئيسي: نفس مفتاح الشاشة الرئيسية =====
          MasterSwitchCard(
            settings: settings,
            city: arabCities[settings.cityIndex.clamp(0, arabCities.length - 1)],
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          const Text(
            'إيقاف المؤذن يلغي كل التنبيهات المجدولة ويوقف أي أذان يعمل فوراً. '
            'تشغيله يطلب الأذونات ويعيد جدولة كل الصلوات.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          const Divider(height: 32),
          const Text('المدينة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: settings.cityIndex.clamp(0, arabCities.length - 1),
            decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_city)),
            items: [
              for (var i = 0; i < arabCities.length; i++)
                DropdownMenuItem(value: i, child: Text('${arabCities[i].nameAr} — ${arabCities[i].country}')),
            ],
            onChanged: (v) {
              if (v != null) onChanged(settings.copyWith(cityIndex: v));
            },
          ),
          SwitchListTile(
            title: const Text('استخدام GPS لتحديد موقعي'),
            subtitle: const Text('اختياري — التطبيق يعمل كاملاً بالمدن الجاهزة بدون موقع'),
            value: settings.useGps,
            onChanged: (v) async {
              if (v) {
                await _requestGps(context);
              } else {
                onChanged(settings.copyWith(useGps: false));
              }
            },
          ),
          const Divider(height: 32),
          const Text('طريقة حساب المواقيت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: calculationMethodLabels.containsKey(settings.methodKey)
                ? settings.methodKey
                : 'muslim_world_league',
            decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.calculate)),
            items: [
              for (final e in calculationMethodLabels.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) {
              if (v != null) onChanged(settings.copyWith(methodKey: v));
            },
          ),
          SwitchListTile(
            title: const Text('المذهب الحنفي لصلاة العصر'),
            subtitle: Text(settings.hanafi ? 'العصر: حنفي (ظلّان)' : 'العصر: شافعي / مالكي / حنبلي (ظلّ واحد)'),
            value: settings.hanafi,
            onChanged: (v) => onChanged(settings.copyWith(hanafi: v)),
          ),
          const Divider(height: 32),
          const Text('إشعارات الصلوات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          for (final e in _prayerNames.entries)
            SwitchListTile(
              title: Text('تنبيه صلاة ${e.value}'),
              value: settings.prayerNotifications[e.key] ?? true,
              onChanged: (v) {
                final updated = Map<String, bool>.from(settings.prayerNotifications);
                updated[e.key] = v;
                onChanged(settings.copyWith(prayerNotifications: updated));
              },
            ),
          const Divider(height: 24),
          SwitchListTile(
            title: const Text('تشغيل صوت الأذان'),
            subtitle: const Text(
                'يُذاع الأذان كاملاً عند دخول وقت الصلاة. عند الإيقاف يصلك تنبيه بصوت الجهاز فقط'),
            secondary: const Icon(Icons.volume_up),
            value: settings.adhanSound,
            onChanged: (v) async {
              final updated = settings.copyWith(adhanSound: v);
              onChanged(updated);
              // إعادة الجدولة فوراً بالقناة المناسبة إن كانت التنبيهات فعّالة
              if (updated.alertsActive) {
                final city =
                    arabCities[updated.cityIndex.clamp(0, arabCities.length - 1)];
                final now = DateTime.now();
                await NotificationService.instance.enableAll(
                  today: PrayerService.forDate(
                      lat: city.lat, lng: city.lng, date: now,
                      methodKey: updated.methodKey, hanafi: updated.hanafi),
                  tomorrow: PrayerService.forDate(
                      lat: city.lat, lng: city.lng,
                      date: now.add(const Duration(days: 1)),
                      methodKey: updated.methodKey, hanafi: updated.hanafi),
                  enabled: updated.prayerNotifications,
                  adhanSound: v,
                );
              }
            },
          ),
          const _AdhanPreviewTile(),
          TextButton.icon(
            onPressed: () async {
              await NotificationService.instance.cancelAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إلغاء جميع الإشعارات المجدولة')),
                );
              }
            },
            icon: const Icon(Icons.notifications_off),
            label: const Text('إلغاء كل الإشعارات المجدولة'),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            secondary: const Icon(Icons.dark_mode),
            value: settings.darkMode,
            onChanged: (v) => onChanged(settings.copyWith(darkMode: v)),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'الخصوصية: المؤذن لا يجمع أي بيانات، لا حسابات، لا إعلانات، '
                'لا Firebase ولا أدوات تتبّع. كل شيء يبقى على جهازك.',
                style: TextStyle(height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'صوت الأذان: تسجيل «Azan» بصوت Andrewler، من Wikimedia Commons، '
                'مرخّص برخصة المشاع الإبداعي CC BY-SA 4.0 — يُستخدم دون تعديل، '
                'والنسبة لصاحبه شرط من شروط الرخصة.\n'
                'commons.wikimedia.org/wiki/File:Azan.ogg',
                style: TextStyle(height: 1.6, fontSize: 13, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // سياسة الخصوصية داخل التطبيق — متطلب Google Play
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سياسة الخصوصية'),
            subtitle: const Text('لا جمع بيانات • لا إعلانات • لا تتبّع — النص الكامل'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// معاينة صوت الأذان داخل الإعدادات: تشغيل/إيقاف التسجيل المدمج.
class _AdhanPreviewTile extends StatefulWidget {
  const _AdhanPreviewTile();

  @override
  State<_AdhanPreviewTile> createState() => _AdhanPreviewTileState();
}

class _AdhanPreviewTileState extends State<_AdhanPreviewTile> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
    } else {
      await _player.play(AssetSource('audio/adhan.mp3'));
      if (mounted) setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_playing ? Icons.stop_circle : Icons.play_circle_fill,
          color: const Color(0xFF0E7A5F), size: 32),
      title: Text(_playing ? 'إيقاف المعاينة' : 'استمع إلى الأذان'),
      subtitle: const Text('معاينة التسجيل الذي سيُذاع عند دخول وقت الصلاة'),
      onTap: _toggle,
    );
  }
}
