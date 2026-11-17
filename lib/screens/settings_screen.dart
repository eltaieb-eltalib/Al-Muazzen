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

  /// تفعيل GPS فعلياً: إذن + قراءة الموقع الحقيقي وحفظ إحداثياته،
  /// فتُحسب المواقيت والقبلة والتنبيهات منه (لا إذن بلا استخدام).
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
      onChanged(settings.copyWith(useGps: false, clearGps: true));
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      onChanged(settings.copyWith(
        useGps: true,
        gpsLat: pos.latitude,
        gpsLng: pos.longitude,
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديد موقعك — ستُحسب المواقيت والقبلة منه')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحديد الموقع الآن — تأكد أن GPS يعمل ثم حاول مجدداً')),
        );
      }
      onChanged(settings.copyWith(useGps: false, clearGps: true));
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
            city: effectiveCityFor(settings),
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
                onChanged(settings.copyWith(useGps: false, clearGps: true));
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
          _ExactAlarmNotice(masterEnabled: settings.masterEnabled),
          const Divider(height: 24),
          SwitchListTile(
            title: const Text('تشغيل صوت الأذان'),
            subtitle: const Text(
                'يُذاع الأذان كاملاً عند دخول وقت الصلاة. عند الإيقاف يصلك تنبيه بصوت الجهاز فقط'),
            secondary: const Icon(Icons.volume_up),
            value: settings.adhanSound,
            // إعادة الجدولة بالقناة المناسبة تتم مركزياً في main عند
            // أي تغيير للإعدادات — لا حاجة لجدولة محلية هنا.
            onChanged: (v) => onChanged(settings.copyWith(adhanSound: v)),
          ),
          const _AdhanPreviewTile(),
          // إيقاف فعلي: يُطفئ المفتاح الرئيسي ويلغي كل التنبيهات.
          // (زر «إلغاء فقط» لم يعد له معنى: أي تغيير إعدادات يعيد الجدولة.)
          TextButton.icon(
            onPressed: settings.masterEnabled
                ? () async {
                    await NotificationService.instance.stopAll();
                    onChanged(settings.copyWith(
                      masterEnabled: false,
                      clearMutedUntil: true,
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إيقاف المؤذن وإلغاء كل التنبيهات')),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.notifications_off),
            label: const Text('إيقاف المؤذن وإلغاء كل التنبيهات'),
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

/// تنبيه داخل الإعدادات يظهر فقط عندما يكون المؤذن مفعّلاً وإذن
/// المنبّه الدقيق غير ممنوح: بدون الإذن تُستخدم الجدولة غير الدقيقة،
/// وقد تتأخر التنبيهات في وضع توفير الطاقة. زر «منح الإذن» يفتح
/// صفحة إعداد النظام الخاصة بالإذن، ويختفي التنبيه عند منحه.
class _ExactAlarmNotice extends StatefulWidget {
  final bool masterEnabled;
  const _ExactAlarmNotice({required this.masterEnabled});

  @override
  State<_ExactAlarmNotice> createState() => _ExactAlarmNoticeState();
}

class _ExactAlarmNoticeState extends State<_ExactAlarmNotice> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(covariant _ExactAlarmNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    // أعد الفحص عند تشغيل المؤذن من هذه الشاشة نفسها.
    if (widget.masterEnabled && !oldWidget.masterEnabled) _check();
  }

  Future<void> _check() async {
    if (!widget.masterEnabled) return;
    final can = await NotificationService.instance.canScheduleExactAlarms();
    if (mounted) setState(() => _show = !can);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show || !widget.masterEnabled) return const SizedBox.shrink();
    return Card(
      color: const Color(0xFFFFF3E0),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التنبيهات قد تتأخر في وضع توفير الطاقة بدون إذن المنبّه الدقيق. '
              'امنح الإذن لتصلك تنبيهات الصلاة في وقتها تماماً.',
              style: TextStyle(height: 1.6),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () async {
                  await NotificationService.instance
                      .requestExactAlarmPermission();
                  await _check();
                },
                child: const Text('منح الإذن'),
              ),
            ),
          ],
        ),
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
