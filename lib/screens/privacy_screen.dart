import 'package:flutter/material.dart';

/// سياسة الخصوصية داخل التطبيق — Google Play يطلبها داخل التطبيق
/// وفي Play Console معاً. النص مطابق لملف PRIVACY_POLICY.md في المشروع.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _arabic = '''
باختصار: المؤذن لا يجمع أي بيانات إطلاقاً.

• لا جمع للبيانات: لا نجمع ولا نخزّن على أي خادم ولا نشارك أي بيانات شخصية أو بيانات استخدام.
• لا إعلانات: لا يحتوي التطبيق على أي شبكة أو مكتبة إعلانية.
• لا تتبّع ولا تحليلات: لا Firebase، لا Google Analytics، لا أدوات تتبّع من أي نوع.
• لا حسابات: لا تسجيل دخول ولا بريد ولا رقم هاتف.
• الموقع: إن فعّلت GPS بنفسك، تُستخدم إحداثياتك على جهازك فقط لحساب مواقيت الصلاة والقبلة. يُحفظ آخر موقع محلياً على جهازك فقط، ويُحذف عند إيقاف GPS أو حذف التطبيق. لا يُرسل إلى أي خادم ولا يُشارك أبداً. ويمكن استخدام التطبيق كاملاً بدون موقع باختيار مدينة جاهزة.
• الإعدادات: تُحفظ محلياً على جهازك فقط وتُحذف بحذف التطبيق.
• الإشعارات: تُجدول محلياً على الجهاز، بلا أي خادم سحابي.
• الأطفال: التطبيق غير مصمّم للأطفال دون 13 عاماً كجمهور أساسي، ولا يجمع بيانات من أي شخص.
• التواصل: عبر صفحة التطبيق على Google Play.
''';

  static const _english = '''
In short: Al-Muazzen collects no data at all.

• No data collection, no server storage, no data sharing.
• No ads and no ads SDKs.
• No tracking or analytics: no Firebase, no Google Analytics, no trackers.
• No accounts, email, or phone number.
• Location: only if you enable GPS yourself, coordinates are processed on-device only for prayer times and Qibla. Your last location is kept locally on your device only and is deleted when you turn GPS off or uninstall the app. Never sent to any server, never shared. The app works fully without location using the built-in city list.
• Settings are stored locally on your device only and deleted on uninstall.
• Notifications are scheduled locally; no cloud push service.
• Not designed for children under 13 as a primary audience; no data is collected from anyone.
• Contact: via the app's Google Play listing.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('سياسة الخصوصية — المؤذن',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('آخر تحديث: 15 نوفمبر 2026', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          Text(_arabic, style: TextStyle(height: 1.8, fontSize: 15)),
          Divider(height: 40),
          Text('Privacy Policy — Al-Muazzen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(_english, style: TextStyle(height: 1.7, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
