import 'package:al_muazzen/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Master switch & mute state', () {
    test('defaults: master ON, not muted, alerts active', () {
      const s = AppSettings();
      expect(s.masterEnabled, isTrue);
      expect(s.isMuted, isFalse);
      expect(s.alertsActive, isTrue);
    });

    test('master OFF => alerts inactive', () {
      const s = AppSettings();
      final off = s.copyWith(masterEnabled: false);
      expect(off.alertsActive, isFalse);
    });

    test('future mutedUntil => muted & alerts inactive', () {
      final s = const AppSettings().copyWith(
        mutedUntil: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(s.isMuted, isTrue);
      expect(s.alertsActive, isFalse);
    });

    test('past mutedUntil => no longer muted', () {
      final s = const AppSettings().copyWith(
        mutedUntil: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(s.isMuted, isFalse);
      expect(s.alertsActive, isTrue);
    });

    test('clearMutedUntil removes mute', () {
      final s = const AppSettings()
          .copyWith(mutedUntil: DateTime.now().add(const Duration(hours: 1)))
          .copyWith(clearMutedUntil: true);
      expect(s.mutedUntil, isNull);
      expect(s.alertsActive, isTrue);
    });
  });

  group('GPS coordinates & clearGps', () {
    const withGps = AppSettings(useGps: true, gpsLat: 15.5007, gpsLng: 32.5599);

    test('ordinary copyWith preserves coordinates', () {
      final s = withGps.copyWith(darkMode: true);
      expect(s.gpsLat, 15.5007);
      expect(s.gpsLng, 32.5599);
      expect(s.useGps, isTrue);
    });

    test('copyWith can update coordinates', () {
      final s = withGps.copyWith(gpsLat: 30.0444, gpsLng: 31.2357);
      expect(s.gpsLat, 30.0444);
      expect(s.gpsLng, 31.2357);
    });

    test('clearGps nulls coordinates when turning GPS off', () {
      final s = withGps.copyWith(useGps: false, clearGps: true);
      expect(s.useGps, isFalse);
      expect(s.gpsLat, isNull);
      expect(s.gpsLng, isNull);
    });

    test('clearGps wins even if coordinates are also passed', () {
      final s = withGps.copyWith(gpsLat: 1.0, gpsLng: 2.0, clearGps: true);
      expect(s.gpsLat, isNull);
      expect(s.gpsLng, isNull);
    });

    test('save after clearGps removes stored coordinates', () async {
      SharedPreferences.setMockInitialValues({});
      final service = SettingsService();
      await service.save(withGps);
      var loaded = await service.load();
      expect(loaded.gpsLat, 15.5007);
      expect(loaded.gpsLng, 32.5599);

      await service.save(withGps.copyWith(useGps: false, clearGps: true));
      loaded = await service.load();
      expect(loaded.useGps, isFalse);
      expect(loaded.gpsLat, isNull);
      expect(loaded.gpsLng, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('gps_lat'), isFalse);
      expect(prefs.containsKey('gps_lng'), isFalse);
    });
  });
}
