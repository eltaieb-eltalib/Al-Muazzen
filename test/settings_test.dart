import 'package:al_muazzen/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
