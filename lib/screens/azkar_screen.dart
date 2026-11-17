import 'package:flutter/material.dart';

import '../data/azkar.dart';

/// أذكار الصباح والمساء مع عدّاد لكل ذِكر.
class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  // المتبقّي لكل ذِكر في كل تبويب
  final Map<String, List<int>> _remaining = {};

  List<int> _countersFor(String tabKey, List<Dhikr> list) {
    return _remaining.putIfAbsent(tabKey, () => list.map((d) => d.repeat).toList());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Widget _buildList(String tabKey, List<Dhikr> list) {
    final counters = _countersFor(tabKey, list);
    final total = list.fold<int>(0, (a, d) => a + d.repeat);
    final done = total - counters.fold<int>(0, (a, b) => a + b);
    final progress = total == 0 ? 0.0 : done / total;

    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 6),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('أنجزت $done من $total  •  ${(progress * 100).round()}٪'),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final dhikr = list[i];
              final left = counters[i];
              final finished = left == 0;
              return Card(
                color: finished ? const Color(0xFF0E7A5F).withOpacity(0.10) : null,
                child: InkWell(
                  onTap: finished
                      ? null
                      : () => setState(() => counters[i] = left - 1),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dhikr.text, style: const TextStyle(fontSize: 16, height: 1.7)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              avatar: Icon(finished ? Icons.check : Icons.repeat, size: 16),
                              label: Text(finished ? 'تمّ ✓' : 'المتبقّي: $left / ${dhikr.repeat}'),
                            ),
                            const Spacer(),
                            Text(dhikr.source, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        TextButton.icon(
          onPressed: () => setState(() {
            _remaining[tabKey] = list.map((d) => d.repeat).toList();
          }),
          icon: const Icon(Icons.restart_alt),
          label: const Text('إعادة تعيين الكل'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'أذكار الصباح'), Tab(text: 'أذكار المساء')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList('morning', morningAzkar),
          _buildList('evening', eveningAzkar),
        ],
      ),
    );
  }
}
