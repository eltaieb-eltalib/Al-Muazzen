import 'package:flutter/material.dart';

import '../data/cities.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';

/// منطق المفتاح الرئيسي المشترك بين الرئيسية والإعدادات:
/// ON  = أذونات + جدولة اليوم والغد. OFF = إلغاء كل شيء + إيقاف الصوت.
Future<AppSettings> applyMasterToggle({
  required AppSettings settings,
  required City city,
  required bool turnOn,
}) async {
  if (!turnOn) {
    await NotificationService.instance.stopAll();
    return settings.copyWith(masterEnabled: false);
  }
  final updated = settings.copyWith(masterEnabled: true, clearMutedUntil: true);
  final now = DateTime.now();
  final today = PrayerService.forDate(
    lat: city.lat, lng: city.lng, date: now,
    methodKey: updated.methodKey, hanafi: updated.hanafi,
  );
  final tomorrow = PrayerService.forDate(
    lat: city.lat, lng: city.lng, date: now.add(const Duration(days: 1)),
    methodKey: updated.methodKey, hanafi: updated.hanafi,
  );
  await NotificationService.instance.enableAll(
    today: today,
    tomorrow: tomorrow,
    enabled: updated.prayerNotifications,
    adhanSound: updated.adhanSound,
  );
  return updated;
}

/// المفتاح الرئيسي الكبير والواضح: «المؤذن» يعمل / متوقف.
/// يظهر أعلى الشاشة الرئيسية وأعلى الإعدادات.
class MasterSwitchCard extends StatelessWidget {
  final AppSettings settings;
  final City city;
  final ValueChanged<AppSettings> onChanged;
  const MasterSwitchCard({
    super.key,
    required this.settings,
    required this.city,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final on = settings.masterEnabled;
    final muted = settings.isMuted;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              on ? Icons.volume_up : Icons.volume_off,
              size: 34,
              color: on ? const Color(0xFF0E7A5F) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المؤذن',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    !on
                        ? 'متوقف — لا تنبيهات ولا أذان'
                        : muted
                            ? 'يعمل لكنه صامت مؤقتاً'
                            : 'يعمل — تنبيه عند كل صلاة',
                    style: TextStyle(color: on ? const Color(0xFF0E7A5F) : Colors.grey),
                  ),
                ],
              ),
            ),
            // مفتاح كبير يسهل لمسه
            Transform.scale(
              scale: 1.35,
              child: Switch(
                value: on,
                activeColor: const Color(0xFF0E7A5F),
                onChanged: (v) async {
                  final updated = await applyMasterToggle(
                    settings: settings, city: city, turnOn: v,
                  );
                  onChanged(updated);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
