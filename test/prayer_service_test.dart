import 'package:al_muazzen/services/prayer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrayerService — Cairo', () {
    // القاهرة: 30.0444, 31.2357 — تاريخ ثابت لاختبار حتمي
    final day = PrayerService.forDate(
      lat: 30.0444,
      lng: 31.2357,
      date: DateTime(2026, 1, 15),
      methodKey: 'egyptian',
    );

    test('prayer times are strictly ordered fajr<sunrise<dhuhr<asr<maghrib<isha', () {
      expect(day.fajr.isBefore(day.sunrise), isTrue, reason: 'fajr < sunrise');
      expect(day.sunrise.isBefore(day.dhuhr), isTrue, reason: 'sunrise < dhuhr');
      expect(day.dhuhr.isBefore(day.asr), isTrue, reason: 'dhuhr < asr');
      expect(day.asr.isBefore(day.maghrib), isTrue, reason: 'asr < maghrib');
      expect(day.maghrib.isBefore(day.isha), isTrue, reason: 'maghrib < isha');
    });

    test('all list has 6 entries with Arabic names', () {
      expect(day.all.length, 6);
      expect(day.all.map((p) => p.nameAr),
          containsAll(['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء']));
    });

    test('fivePrayers excludes sunrise', () {
      expect(day.fivePrayers.length, 5);
      expect(day.fivePrayers.any((p) => p.key == 'sunrise'), isFalse);
    });
  });

  group('Qibla', () {
    test('Cairo qibla is roughly south-east (~136 degrees)', () {
      final angle = PrayerService.qiblaDirection(30.0444, 31.2357);
      expect(angle, inInclusiveRange(120, 155));
    });

    test('Makkah-adjacent point still returns 0-360 range', () {
      final angle = PrayerService.qiblaDirection(24.7136, 46.6753); // Riyadh
      expect(angle, inInclusiveRange(0, 360));
    });
  });

  group('Calculation methods', () {
    test('all 9 method keys resolve without throwing', () {
      for (final key in calculationMethodLabels.keys) {
        final params = PrayerService.paramsFromKey(key);
        expect(params, isNotNull);
      }
    });

    test('unknown key falls back safely', () {
      final day = PrayerService.forDate(
        lat: 30.0444,
        lng: 31.2357,
        date: DateTime(2026, 1, 15),
        methodKey: 'unknown_key',
      );
      expect(day.fajr.isBefore(day.isha), isTrue);
    });

    test('Hanafi Asr is later than or equal to Shafi Asr', () {
      final shafi = PrayerService.forDate(
        lat: 30.0444, lng: 31.2357, date: DateTime(2026, 6, 15), methodKey: 'egyptian',
      );
      final hanafi = PrayerService.forDate(
        lat: 30.0444, lng: 31.2357, date: DateTime(2026, 6, 15), methodKey: 'egyptian', hanafi: true,
      );
      expect(hanafi.asr.isAfter(shafi.asr) || hanafi.asr.isAtSameMomentAs(shafi.asr), isTrue);
    });
  });

  group('Next prayer', () {
    test('before fajr, next is fajr', () {
      final day = PrayerService.forDate(
        lat: 30.0444, lng: 31.2357, date: DateTime(2026, 1, 15), methodKey: 'egyptian',
      );
      final beforeFajr = day.fajr.subtract(const Duration(hours: 1));
      expect(PrayerService.nextPrayer(day, beforeFajr).key, 'fajr');
    });

    test('after isha, next is next-day fajr', () {
      final day = PrayerService.forDate(
        lat: 30.0444, lng: 31.2357, date: DateTime(2026, 1, 15), methodKey: 'egyptian',
      );
      final afterIsha = day.isha.add(const Duration(minutes: 5));
      final next = PrayerService.nextPrayer(day, afterIsha);
      expect(next.key, 'fajr');
      expect(next.time.isAfter(day.isha), isTrue);
    });
  });
}
