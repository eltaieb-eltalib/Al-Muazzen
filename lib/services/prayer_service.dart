import 'package:adhan/adhan.dart';

/// أسماء الصلوات بالعربية مع مفتاحها.
class PrayerInfo {
  final String key;
  final String nameAr;
  final DateTime time;
  const PrayerInfo({required this.key, required this.nameAr, required this.time});
}

/// مواقيت يوم كامل.
class PrayerDay {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerDay({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerInfo> get all => [
        PrayerInfo(key: 'fajr', nameAr: 'الفجر', time: fajr),
        PrayerInfo(key: 'sunrise', nameAr: 'الشروق', time: sunrise),
        PrayerInfo(key: 'dhuhr', nameAr: 'الظهر', time: dhuhr),
        PrayerInfo(key: 'asr', nameAr: 'العصر', time: asr),
        PrayerInfo(key: 'maghrib', nameAr: 'المغرب', time: maghrib),
        PrayerInfo(key: 'isha', nameAr: 'العشاء', time: isha),
      ];

  /// الصلوات الخمس فقط (بدون الشروق) للإشعارات.
  List<PrayerInfo> get fivePrayers =>
      all.where((p) => p.key != 'sunrise').toList();
}

/// خريطة طرق الحساب المتاحة في واجهة الإعدادات.
const Map<String, String> calculationMethodLabels = {
  'umm_al_qura': 'أم القرى - مكة',
  'muslim_world_league': 'رابطة العالم الإسلامي',
  'egyptian': 'الهيئة المصرية العامة للمساحة',
  'north_america': 'أمريكا الشمالية (ISNA)',
  'kuwait': 'الكويت',
  'qatar': 'قطر',
  'dubai': 'دبي - الإمارات',
  'turkey': 'تركيا - الشؤون الدينية',
  'singapore': 'سنغافورة',
};

class PrayerService {
  /// تحويل مفتاح الطريقة النصي إلى CalculationMethod من حزمة adhan.
  static CalculationParameters paramsFromKey(String key, {bool hanafi = false}) {
    final CalculationParameters params = switch (key) {
      'umm_al_qura' => CalculationMethod.umm_al_qura.getParameters(),
      'muslim_world_league' => CalculationMethod.muslim_world_league.getParameters(),
      'egyptian' => CalculationMethod.egyptian.getParameters(),
      'north_america' => CalculationMethod.north_america.getParameters(),
      'kuwait' => CalculationMethod.kuwait.getParameters(),
      'qatar' => CalculationMethod.qatar.getParameters(),
      'dubai' => CalculationMethod.dubai.getParameters(),
      'turkey' => CalculationMethod.turkey.getParameters(),
      'singapore' => CalculationMethod.singapore.getParameters(),
      _ => CalculationMethod.muslim_world_league.getParameters(),
    };
    params.madhab = hanafi ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  static PrayerDay forDate({
    required double lat,
    required double lng,
    required DateTime date,
    required String methodKey,
    bool hanafi = false,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = paramsFromKey(methodKey, hanafi: hanafi);
    final dateComponents = DateComponents.from(date);
    final pt = PrayerTimes(coordinates, dateComponents, params);
    return PrayerDay(
      date: date,
      fajr: pt.fajr,
      sunrise: pt.sunrise,
      dhuhr: pt.dhuhr,
      asr: pt.asr,
      maghrib: pt.maghrib,
      isha: pt.isha,
    );
  }

  static PrayerDay today({
    required double lat,
    required double lng,
    required String methodKey,
    bool hanafi = false,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = paramsFromKey(methodKey, hanafi: hanafi);
    final pt = PrayerTimes.today(coordinates, params);
    final now = DateTime.now();
    return PrayerDay(
      date: DateTime(now.year, now.month, now.day),
      fajr: pt.fajr,
      sunrise: pt.sunrise,
      dhuhr: pt.dhuhr,
      asr: pt.asr,
      maghrib: pt.maghrib,
      isha: pt.isha,
    );
  }

  /// الصلاة القادمة؛ إذا انتهت العشاء فهي فجر الغد.
  static PrayerInfo nextPrayer(PrayerDay day, DateTime now) {
    for (final p in day.all) {
      if (p.time.isAfter(now)) return p;
    }
    // فجر الغد — يُحسب تقريبياً بإضافة يوم لفجر اليوم في واجهة العدّاد
    return PrayerInfo(
      key: 'fajr',
      nameAr: 'الفجر',
      time: day.fajr.add(const Duration(days: 1)),
    );
  }

  /// الصلاة الحالية (آخر صلاة دخل وقتها).
  static PrayerInfo? currentPrayer(PrayerDay day, DateTime now) {
    PrayerInfo? current;
    for (final p in day.all) {
      if (!p.time.isAfter(now)) current = p;
    }
    return current;
  }

  /// اتجاه القبلة بالدرجات من الشمال (0-360).
  static double qiblaDirection(double lat, double lng) {
    return Qibla(Coordinates(lat, lng)).direction;
  }
}
