import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../data/cities.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../widgets/master_switch.dart';

/// الشاشة الرئيسية: المفتاح الرئيسي، التاريخ الهجري، العدّاد، الصلوات.
class HomeScreen extends StatefulWidget {
  final City city;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;
  const HomeScreen({
    super.key,
    required this.city,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// شريط «صامت مؤقتاً»: كتم ساعة واحدة أو حتى الصلاة القادمة.
  /// الكتم لا يلغي الجدولة: إعادة الجدولة المركزية (في main) تتخطّى
  /// الصلوات الواقعة داخل فترة الكتم فقط، فتعود التنبيهات تلقائياً
  /// بانتهاء الكتم — دون فتح التطبيق ودون لمس بقية الأيام.
  Widget _muteBar(PrayerInfo next) {
    final s = widget.settings;
    if (s.isMuted) {
      final until = TimeOfDay.fromDateTime(s.mutedUntil!).format(context);
      return Card(
        color: Colors.amber.shade50,
        child: ListTile(
          leading: const Icon(Icons.volume_off, color: Colors.orange),
          title: Text('صامت مؤقتاً حتى $until'),
          trailing: TextButton(
            onPressed: () =>
                widget.onSettingsChanged(s.copyWith(clearMutedUntil: true)),
            child: const Text('إلغاء الكتم'),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.volume_off, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('صامت مؤقتاً:'),
            const Spacer(),
            TextButton(
              onPressed: () {
                widget.onSettingsChanged(s.copyWith(
                  mutedUntil: DateTime.now().add(const Duration(hours: 1)),
                ));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم الكتم لمدة ساعة واحدة 🔕')));
                }
              },
              child: const Text('ساعة واحدة'),
            ),
            TextButton(
              onPressed: () {
                widget.onSettingsChanged(s.copyWith(mutedUntil: next.time));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('تم الكتم حتى صلاة ${next.nameAr} 🔕')));
                }
              },
              child: const Text('حتى الصلاة القادمة'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final day = PrayerService.today(
      lat: widget.city.lat,
      lng: widget.city.lng,
      methodKey: widget.settings.methodKey,
      hanafi: widget.settings.hanafi,
    );
    final next = PrayerService.nextPrayer(day, _now);
    final remaining = next.time.difference(_now);
    final hijri = HijriCalendar.now();
    const hijriMonthsAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    // أوقات بأرقام لاتينية داخل اتجاه LTR: عرض ثابت وسليم في كل المنصات
    // (أرقام عربية مشرقية داخل نص RTL قد تنعكس في بعض محركات العرض).
    String fmtTime(DateTime t) {
      final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final hh = h12.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm ${t.hour < 12 ? 'ص' : 'م'}';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3D2E), Color(0xFF0E7A5F), Color(0xFFF4F7F5)],
            stops: [0.0, 0.35, 0.36],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== المفتاح الرئيسي: تشغيل / إيقاف المؤذن =====
              MasterSwitchCard(
                settings: widget.settings,
                city: widget.city,
                onChanged: widget.onSettingsChanged,
              ),
              if (!widget.settings.masterEnabled)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'المؤذن متوقف الآن — فعّل المفتاح بالأعلى لاستئناف التنبيهات والأذان.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              // ===== صامت مؤقتاً =====
              if (widget.settings.masterEnabled) _muteBar(next),
              // تنبيه المنبّه الدقيق: يظهر فقط إن كان الإذن غير ممنوح
              if (widget.settings.masterEnabled) const _ExactAlarmHint(),
              const SizedBox(height: 8),
              Text(
                '${hijri.hDay} ${hijriMonthsAr[hijri.hMonth - 1]} ${hijri.hYear} هـ',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('EEEE، d MMMM yyyy', 'ar').format(_now),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 18),
                  Text(
                      widget.city.country.isEmpty
                          ? widget.city.nameAr
                          : '${widget.city.nameAr}، ${widget.city.country}',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
              // بطاقة العدّاد — زجاجية (Glass)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                    ),
                    child: Column(
                      children: [
                        Text('الصلاة القادمة: ${next.nameAr}',
                            style: const TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                          _formatCountdown(remaining.isNegative ? Duration.zero : remaining),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text('الساعة ${fmtTime(next.time)}',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    for (final p in day.all)
                      ListTile(
                        leading: Icon(
                          p.key == next.key ? Icons.notifications_active : Icons.access_time,
                          color: p.key == next.key
                              ? const Color(0xFF0E7A5F)
                              : Theme.of(context).colorScheme.outline,
                        ),
                        title: Text(
                          p.nameAr,
                          style: TextStyle(
                            fontWeight: p.key == next.key ? FontWeight.bold : FontWeight.normal,
                            color: p.key == next.key ? const Color(0xFF0E7A5F) : null,
                          ),
                        ),
                        trailing: Text(
                          fmtTime(p.time),
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontWeight: p.key == next.key ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        tileColor: p.key == next.key
                            ? const Color(0xFF0E7A5F).withOpacity(0.08)
                            : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'جميع الحسابات تتم على جهازك — لا إنترنت ولا تتبّع.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة تنبيه تظهر فقط عندما يكون إذن المنبّه الدقيق غير ممنوح:
/// التنبيهات تعمل بالوضع غير الدقيق وقد تتأخر في وضع توفير الطاقة،
/// فندعو المستخدم لمنح الإذن بضغطة واحدة.
class _ExactAlarmHint extends StatefulWidget {
  const _ExactAlarmHint();

  @override
  State<_ExactAlarmHint> createState() => _ExactAlarmHintState();
}

class _ExactAlarmHintState extends State<_ExactAlarmHint> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await NotificationService.instance.canScheduleExactAlarms();
    if (mounted) setState(() => _show = !ok);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return Card(
      color: Colors.amber.shade50,
      child: ListTile(
        leading: const Icon(Icons.alarm_off, color: Colors.orange),
        title: const Text('التنبيهات قد تتأخر'),
        subtitle: const Text(
            'إذن «المنبّه الدقيق» غير ممنوح، وفي وضع توفير الطاقة قد يصلك الأذان متأخراً. امنح الإذن ليصل في وقته تماماً.'),
        trailing: TextButton(
          onPressed: () async {
            await NotificationService.instance.requestPermissions();
            await _check();
          },
          child: const Text('منح الإذن'),
        ),
      ),
    );
  }
}
