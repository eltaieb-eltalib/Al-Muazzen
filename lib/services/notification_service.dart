import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_service.dart';

/// معرف إجراء «إيقاف الأذان» داخل الإشعار.
const String kStopAdhanActionId = 'stop_adhan';

/// خدمة الإشعارات المحلية — تنبيه عند دخول وقت كل صلاة.
/// لا تستخدم Firebase ولا أي خدمة سحابية.
///
/// التشغيل/الإيقاف السهل:
/// - [enableAll]: جدولة صلوات ٧ أيام (والأذونات فقط عند طلبها صراحة).
/// - [stopAll]: إلغاء كل الإشعارات المجدولة + إيقاف أي صوت أذان يعمل فوراً.
/// - إعادة التشغيل (Boot): الإشعارات المجدولة تُستعاد تلقائياً بواسطة
///   ScheduledNotificationBootReceiver في AndroidManifest، فلا يحتاج
///   المستخدم لفتح التطبيق بعد إعادة تشغيل هاتفه.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// هل صوت أذان يعمل الآن؟ (صوت القناة يشغّله نظام أندرويد نفسه عند
  /// ظهور الإشعار، وإلغاء الإشعار الظاهر يوقفه.)
  bool isAdhanPlaying = false;

  /// زر «إيقاف الأذان» داخل الإشعار نفسه — حيثما يدعم النظام ذلك.
  static const _stopAction = AndroidNotificationAction(
    kStopAdhanActionId,
    'إيقاف الأذان',
    showsUserInterface: false,
    cancelNotification: true,
  );

  /// قناة التنبيه بصوت الجهاز الافتراضي (عند إيقاف صوت الأذان).
  static const AndroidNotificationDetails _defaultDetails =
      AndroidNotificationDetails(
    'adhan_channel',
    'تنبيهات الصلاة',
    channelDescription: 'تنبيه عند دخول وقت الصلاة',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    actions: <AndroidNotificationAction>[_stopAction],
  );

  /// قناة الأذان الكامل: صوتها هو ملف الأذان المرخّص في res/raw،
  /// ويشغّله النظام على مستوى صوت المنبّه حتى لو كان التطبيق مغلقاً.
  /// التسجيل: Andrewler عبر Wikimedia Commons — رخصة CC BY-SA 4.0
  /// (انظر assets/audio/ATTRIBUTION.md).
  static const AndroidNotificationDetails _adhanDetails =
      AndroidNotificationDetails(
    'adhan_sound_channel',
    'تنبيهات الصلاة بصوت الأذان',
    channelDescription: 'يُذاع الأذان كاملاً عند دخول وقت الصلاة',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('adhan'),
    audioAttributesUsage: AudioAttributesUsage.alarm,
    actions: <AndroidNotificationAction>[_stopAction],
  );

  static NotificationDetails _detailsFor(bool adhanSound) =>
      NotificationDetails(android: adhanSound ? _adhanDetails : _defaultDetails);

  Future<void> init() async {
    if (_initialized) return;
    // الإشعارات المحلية غير مدعومة على الويب — ولا يجب أن يمنع أي فشل
    // في تهيئتها إقلاع التطبيق أبداً.
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    try {
      tz_data.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      settings,
      // الضغط على الإشعار أو على زر «إيقاف الأذان» يوقف الصوت فوراً:
      // إلغاء الإشعار الظاهر يوقف صوت القناة الذي يشغّله النظام.
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == kStopAdhanActionId ||
            response.payload == 'adhan') {
          instance.stopAdhanSound();
          if (response.id != null) instance._plugin.cancel(response.id!);
        }
      },
        onDidReceiveBackgroundNotificationResponse: _backgroundResponse,
      );
      _initialized = true;
    } catch (_) {
      // فشلت التهيئة (منصة غير مدعومة مثلاً): نتابع دون إشعارات.
      _initialized = true;
    }
  }

  @pragma('vm:entry-point')
  static void _backgroundResponse(NotificationResponse response) {
    if (response.actionId == kStopAdhanActionId) {
      // في الخلفية: إلغاء الإشعار الظاهر يوقف صوت القناة.
      instance._plugin.cancel(response.id ?? 0);
    }
  }

  /// طلب كل الأذونات اللازمة في تدفق واحد بسيط (يُستدعى عند تشغيل المؤذن
  /// بفعل صريح من المستخدم فقط — أبداً عند كل فتح للتطبيق).
  /// 1) إذن الإشعارات (Android 13+)  2) إذن المنبّه الدقيق من إعدادات
  /// النظام — ولا يُفتح إعداد النظام إلا إن كان الإذن غير ممنوح فعلاً.
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    final canExact = await android?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await android?.requestExactAlarmsPermission();
    }
  }

  /// وضع الجدولة الآمن: منبّه دقيق إن كان إذنه ممنوحاً، وإلا غير دقيق.
  /// على Android 14+ إذن المنبّه الدقيق مرفوض افتراضياً، والجدولة
  /// الدقيقة بدونه ترمي استثناءً — فلا بد من هذا الفحص حتى لا تتعطّل
  /// كل التنبيهات بصمت.
  Future<AndroidScheduleMode> _bestScheduleMode() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await android?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// إيقاف صوت الأذان فوراً (إن كان يعمل) — دون المساس بالإشعارات
  /// المجدولة القادمة. صوت الأذان يشغّله نظام أندرويد كصوت لقناة
  /// الإشعار، وإلغاء الإشعارات الظاهرة (من معالجات الاستجابة أعلاه
  /// أو من stopAll) يوقفه.
  Future<void> stopAdhanSound() async {
    isAdhanPlaying = false;
  }

  /// ⛔ إيقاف كل شيء: إلغاء جميع الإشعارات المجدولة + إيقاف الصوت فوراً.
  /// هذا ما يفعله المفتاح الرئيسي عند وضعه على OFF.
  Future<void> stopAll() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    isAdhanPlaying = false;
    await _plugin.cancelAll();
  }

  /// ✅ تشغيل كل شيء: جدولة صلوات [days] (٧ أيام) حسب التفعيل لكل صلاة.
  /// هذا ما يفعله المفتاح الرئيسي عند وضعه على ON.
  /// [askPermissions] تُفعَّل فقط من فعل صريح للمستخدم (تشغيل المفتاح) —
  /// إعادة الجدولة الصامتة عند فتح التطبيق أو تغيير إعداد لا تطلب أذونات.
  /// [mutedUntil]: الصلوات الواقعة داخل فترة الكتم لا تُجدول أصلاً،
  /// فتعود التنبيهات تلقائياً بعد انتهاء الكتم دون أي تدخّل.
  Future<void> enableAll({
    required List<PrayerDay> days,
    required Map<String, bool> enabled,
    bool adhanSound = true,
    bool askPermissions = true,
    DateTime? mutedUntil,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    if (askPermissions) await requestPermissions();
    await _plugin.cancelAll(); // تجنّب التكرار قبل إعادة الجدولة
    for (var i = 0; i < days.length; i++) {
      await scheduleForDay(
        days[i],
        enabled,
        idOffset: i * 10,
        adhanSound: adhanSound,
        mutedUntil: mutedUntil,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// جدولة إشعارات صلوات يوم واحد حسب الإعدادات المفعّلة.
  /// id ثابت لكل صلاة: الفجر 1، الظهر 2، العصر 3، المغرب 4، العشاء 5
  /// (+ [idOffset] لأيام أخرى: كل يوم لاحق +10).
  /// الصلوات داخل فترة الكتم [mutedUntil] تُتخطّى — فتستأنف التنبيهات
  /// تلقائياً بعد انتهاء الكتم.
  Future<void> scheduleForDay(
    PrayerDay day,
    Map<String, bool> enabled, {
    int idOffset = 0,
    bool adhanSound = true,
    DateTime? mutedUntil,
  }) async {
    if (!_initialized) await init();
    const ids = {'fajr': 1, 'dhuhr': 2, 'asr': 3, 'maghrib': 4, 'isha': 5};
    final now = DateTime.now();
    var mode = await _bestScheduleMode();
    for (final prayer in day.fivePrayers) {
      if (enabled[prayer.key] != true) continue;
      if (!prayer.time.isAfter(now)) continue;
      if (mutedUntil != null && !prayer.time.isAfter(mutedUntil)) continue;
      final scheduled = tz.TZDateTime.from(prayer.time, tz.local);
      try {
        await _plugin.zonedSchedule(
          (ids[prayer.key] ?? 99) + idOffset,
          'حان الآن وقت صلاة ${prayer.nameAr}',
          'تقبّل الله منا ومنكم صالح الأعمال — اضغط «إيقاف الأذان» للإيقاف',
          scheduled,
          _detailsFor(adhanSound),
          payload: 'adhan',
          androidScheduleMode: mode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        // فشلت الجدولة بالوضع الحالي (غالباً إذن المنبّه الدقيق سُحب):
        // تراجع للوضع غير الدقيق بدل تعطيل بقية الصلوات.
        mode = AndroidScheduleMode.inexactAllowWhileIdle;
        try {
          await _plugin.zonedSchedule(
            (ids[prayer.key] ?? 99) + idOffset,
            'حان الآن وقت صلاة ${prayer.nameAr}',
            'تقبّل الله منا ومنكم صالح الأعمال — اضغط «إيقاف الأذان» للإيقاف',
            scheduled,
            _detailsFor(adhanSound),
            payload: 'adhan',
            androidScheduleMode: mode,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {
          // تخطَّ هذه الصلاة فقط — لا تُسقط بقية الجدولة.
        }
      }
    }
  }
}
