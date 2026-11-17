import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/cities.dart';
import '../services/prayer_service.dart';

/// شاشة القبلة: تعرض زاوية القبلة للمدينة المختارة مع بوصلة مرسومة.
/// ملاحظة: قراءة بوصلة الهاتف الحية (المغناطيس) تحتاج حزمة إضافية
/// مثل flutter_compass — هذه الشاشة تعرض الاتجاه الدقيق المحسوب
/// فلكياً، ويمكن تدوير الهاتف حتى تطابق السهم.
class QiblaScreen extends StatelessWidget {
  final City city;
  const QiblaScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    final angle = PrayerService.qiblaDirection(city.lat, city.lng);
    final radians = angle * math.pi / 180;

    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  city.country.isEmpty
                      ? 'من ${city.nameAr}'
                      : 'من ${city.nameAr}، ${city.country}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // الرقم داخل اتجاه LTR حتى لا ينعكس ترتيبه داخل النص العربي.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('زاوية القبلة: ',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0E7A5F))),
                  Text('${angle.toStringAsFixed(1)}°',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF0E7A5F))),
                  const Text(' من الشمال',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0E7A5F))),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: _CompassPainter(angleRadians: radians),
                  child: Center(
                    child: Transform.rotate(
                      angle: radians,
                      child: const Icon(Icons.navigation, size: 90, color: Color(0xFF0E7A5F)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '🕋\nوجّه السهم نحو الكعبة المشرفة.\nأدر هاتفك حتى يشير السهم للأعلى مع اتجاه الشمال الحقيقي.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.6, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double angleRadians;
  _CompassPainter({required this.angleRadians});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final circlePaint = Paint()
      ..color = const Color(0xFF0E7A5F).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // علامات الدرجات كل 30 درجة
    final tickPaint = Paint()
      ..color = const Color(0xFF0E7A5F)
      ..strokeWidth = 2;
    for (var deg = 0; deg < 360; deg += 30) {
      final r = deg * math.pi / 180;
      final outer = Offset(center.dx + radius * math.sin(r), center.dy - radius * math.cos(r));
      final inner = Offset(
        center.dx + (radius - 12) * math.sin(r),
        center.dy - (radius - 12) * math.cos(r),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // خط القبلة
    final qiblaPaint = Paint()
      ..color = const Color(0xFFC9A227)
      ..strokeWidth = 3;
    final end = Offset(
      center.dx + radius * math.sin(angleRadians),
      center.dy - radius * math.cos(angleRadians),
    );
    canvas.drawLine(center, end, qiblaPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.angleRadians != angleRadians;
}
