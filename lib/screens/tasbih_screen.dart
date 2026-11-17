import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// السبحة الإلكترونية.
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const presets = ['سبحان الله', 'الحمد لله', 'الله أكبر', 'لا إله إلا الله'];
  static const targets = [33, 99, 100];

  String _dhikr = presets.first;
  int _target = 33;
  int _count = 0;
  int _rounds = 0;

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      if (_count >= _target) {
        _count = 0;
        _rounds++;
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أتممت $_target مرة — تقبّل الله 🤲'), duration: const Duration(seconds: 2)),
        );
      }
    });
  }

  void _reset() => setState(() {
        _count = 0;
        _rounds = 0;
      });

  @override
  Widget build(BuildContext context) {
    final progress = _target == 0 ? 0.0 : _count / _target;
    return Scaffold(
      appBar: AppBar(title: const Text('السبحة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    label: Text(p),
                    selected: _dhikr == p,
                    onSelected: (_) => setState(() {
                      _dhikr = p;
                      _reset();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('الهدف: '),
                for (final t in targets)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$t'),
                      selected: _target == t,
                      onSelected: (_) => setState(() {
                        _target = t;
                        _reset();
                      }),
                    ),
                  ),
              ],
            ),
            if (_rounds > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('الجولات المكتملة: $_rounds', style: const TextStyle(color: Color(0xFF0E7A5F), fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            GestureDetector(
              onTap: _increment,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        color: const Color(0xFF0E7A5F),
                        backgroundColor: const Color(0xFF0E7A5F).withOpacity(0.15),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_dhikr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('$_count', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                        Text('من $_target — اضغط للتسبيح', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('تصفير العدّاد'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
