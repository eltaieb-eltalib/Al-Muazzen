# المؤذن — Al-Muazzen 🕌

تطبيق مواقيت صلاة وأذكار عربي بالكامل، يعمل بدون إنترنت، ويحترم خصوصيتك تماماً:
لا حسابات، لا إعلانات، لا Firebase، لا أدوات تتبّع.

An Arabic-first prayer times & azkar app built with Flutter. Fully offline,
privacy-first: no accounts, no ads, no Firebase, no tracking.

---

## 🔍 البحث في المشاريع مفتوحة المصدر — Base Projects Researched

طُوّر هذا المشروع بعد دراسة مشاريع مفتوحة المصدر قائمة. الكود هنا **أصلي بالكامل**
ومكتوب من الصفر باستخدام واجهات الحزم القياسية — لم يُنسخ أي كود GPL.

This project was developed after researching existing open-source apps.
All code here is **original**, written from scratch against standard package
APIs — no GPL code was copied.

| المشروع / Project | الرابط / Link | الترخيص / License | ما استفدنا منه / What inspired us |
|---|---|---|---|
| **Rafeeq** | https://github.com/teamsazen/Rafeeq | MIT | البنية: حزمة `adhan` + `geolocator`، فصل الخدمات عن الواجهات (نمط Riverpod). أعدنا تنفيذ نفس الواجهات العامة بكود أصلي — متوافق مع MIT. |
| **Sakin** | (Arabic, privacy-focused prayer app) | GPLv3 | أفكار المنتج فقط: العربية أولاً + الخصوصية. **لم يُنسخ أي كود** بسبب طبيعة GPL المعدية. |
| **Zakerny** | (Arabic RTL offline-first) | — | أفكار المنتج فقط: تخطيط RTL كامل + العمل بدون إنترنت أولاً. |
| **adhan (Dart)** | https://pub.dev/packages/adhan | MIT | مكتبة حساب مواقيت الصلاة واتجاه القبلة المستخدمة فعلياً في الكود. |

> الشكر والتقدير لمطوّري **Rafeeq** (MIT) — انظر ملف `LICENSE` و `NOTICE` الاعتمادات.

---

## ✨ ما طوّرناه وحسّنّاه — What Was Developed / Improved

- **العربية أولاً و RTL كامل:** واجهة عربية بالكامل، اتجاه من اليمين لليسار في كل الشاشات، تاريخ هجري.
- **الخصوصية أولاً:** لا Firebase، لا Analytics، لا إعلانات، لا خوادم — كل الحسابات على الجهاز.
- **25 مدينة عربية جاهزة بدون إنترنت + GPS اختياري:** القاهرة، الرياض، مكة، المدينة، دبي، الدوحة، الكويت، عمّان، القدس، الخرطوم، الرباط… إلخ. GPS اختياري فقط عند تفعيله من الإعدادات.
- **واجهة زجاجية بلون زمردي (Glass Emerald UI):** بطاقة عدّاد زجاجية `BackdropFilter`، تدرّج زمردي، وضع ليلي.
- **عدّاد تنازلي حي:** يتحدّث كل ثانية نحو الصلاة القادمة مع تمييزها في القائمة.
- **الأذكار + السبحة:** أذكار صباح ومساء (10+10) بعدّاد تنازلي لكل ذِكر وشريط تقدّم، وسبحة إلكترونية بأهداف 33/99/100 واهتزاز عند الإتمام.
- **إشعارات لكل صلاة على حدة:** تفعيل/تعطيل تنبيه كل صلاة من الإعدادات، قناة Android عالية الأهمية، إعادة جدولة بعد إعادة التشغيل.
- **طرق حساب متعددة:** أم القرى، رابطة العالم الإسلامي، الهيئة المصرية، ISNA، الكويت، قطر، دبي، تركيا، سنغافورة + مذهب العصر (شافعي/حنفي).
- **اتجاه القبلة:** محسوب فلكياً بدقة من إحداثيات المدينة مع بوصلة مرسومة.

---

## 🔘 تشغيل / إيقاف سهل — Easy On/Off

- **المفتاح الرئيسي «المؤذن»:** مفتاح كبير وواضح أعلى **الشاشة الرئيسية** وأعلى **الإعدادات** أيضاً.
  - **OFF (إيقاف):** يلغي فوراً كل الإشعارات/المنبّهات المجدولة + يوقف أي صوت أذان يعمل في نفس اللحظة (`NotificationService.stopAll()`).
  - **ON (تشغيل):** يطلب الأذونات اللازمة في تدفق واحد بسيط (إشعارات + منبّه دقيق) ثم يجدول كل صلوات اليوم والغد (`NotificationService.enableAll()`).
  - الحالة **محفوظة** وتُستعاد عند فتح التطبيق.
- **زر «إيقاف الأذان» داخل الإشعار نفسه:** كل إشعار صلاة يحمل إجراء إيقاف، والضغط على الإشعار يوقف الصوت أيضاً.
- **«صامت مؤقتاً» 🔕** من الشاشة الرئيسية: كتم **ساعة واحدة** أو **حتى الصلاة القادمة**، مع زر إلغاء كتم يعيد الجدولة فوراً.
- **إعادة جدولة تلقائية بعد إعادة تشغيل الجهاز (Boot):** إذن `RECEIVE_BOOT_COMPLETED` + مستقبِل `ScheduledNotificationBootReceiver` يعيدان التنبيهات المجدولة تلقائياً — **لا يحتاج المستخدم لفتح التطبيق من جديد بعد إعادة تشغيل هاتفه أبداً.** وعند فتح التطبيق يعيد أيضاً جدولة اليوم والغد لضمان التغطية.

---

## 🏪 النشر على Google Play — Play Compliance (مُتحقق منه نوفمبر 2026)

- **صيغة النشر AAB فقط:** `flutter build appbundle --release` ← الـ APK للاختبار المباشر فقط.
- **targetSdk / compileSdk = 36 (Android 16)** — إلزامي للتطبيقات الجديدة منذ 31 أغسطس 2026. `minSdk = 24`، `applicationId = com.tayeb.almuazzen`، `versionCode 1 / versionName 1.0.0` — كلها مضبوطة في `android/app/build.gradle`.
- **التوقيع:** `build.gradle` يقرأ `android/key.properties` إن وُجد (مفتاح الرفع Upload Key) مع **Play App Signing**؛ لا يوجد أي مفتاح حقيقي في المشروع — انظر `android/key.properties.example`.
- **أذونات دنيا آمنة فقط** (مع تعليق شارح لكل إذن داخل `AndroidManifest.xml`): موقع تقريبي/دقيق في المقدمة فقط (لا موقع خلفي)، `POST_NOTIFICATIONS`، `SCHEDULE_EXACT_ALARM` (التي يمنحها المستخدم — **ليست** `USE_EXACT_ALARM` المقيّدة)، `RECEIVE_BOOT_COMPLETED`، `VIBRATE`. لا `USE_FULL_SCREEN_INTENT` ولا أذونات خدمة أمامية ولا وسائط.
- **لا Firebase، لا Analytics، لا إعلانات — في أي مكان.**
- **سياسة الخصوصية:** ملف [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md) (عربي + إنجليزي) + نفس النص داخل التطبيق (الإعدادات ← سياسة الخصوصية) — كما يطلب Play في المكانين.
- **قائمة النشر الكاملة:** [`PLAY_STORE.md`](PLAY_STORE.md) — الاختبار المغلق (12 مختبِراً × 14 يوماً للحسابات الشخصية الجديدة)، حساب المطوّر 25$، إجابات سلامة البيانات، تقييم المحتوى، الجمهور 13+ وغير مصمّم للأطفال، إقرار «لا إعلانات»، مقاسات أصول المتجر (أيقونة 512×512، صورة مميزة 1024×500، لقطتان على الأقل)، **نص إقرار المنبّه الدقيق جاهز للصق في Play Console**، وشرط أن يكون صوت الأذان ملكية عامة موثّقة المصدر.

---

## 🚀 التشغيل — How to Run

```bash
# 1) تثبيت الاعتماديات
flutter pub get

# 2) التشغيل على جهاز / محاكي
flutter run

# 3) الاختبارات
flutter test

# 4) بناء نسخة Google Play — AAB (هذه هي صيغة النشر الرسمية)
flutter build appbundle --release
# الناتج: build/app/outputs/bundle/release/app-release.aab

# 5) APK للاختبار المباشر على جهازك فقط (لا يُرفع على Play)
flutter build apk --release
# الناتج: build/app/outputs/flutter-apk/app-release.apk

# 6) بناء iOS (على macOS)
flutter build ios --release
```

> قبل أول رفع على Play: انسخ `android/key.properties.example` إلى
> `android/key.properties` واملأ بيانات مفتاح الرفع الخاص بك محلياً،
> وفعّل Play App Signing في Play Console. التفاصيل في `PLAY_STORE.md`.

المتطلبات: Flutter 3.24+ و Dart 3.

> ملاحظة: هذا المستودع يحتوي الكود المصدري الكامل والملفات الأساسية
> (`pubspec.yaml`، `lib/`، `android/app/src/main/AndroidManifest.xml`، `test/`).
> إن لم يوجد هيكل المنصة كاملاً، شغّل مرة واحدة:
> `flutter create --platforms=android,ios --org com.almuazzen .`
> ثم أعد نسخ `AndroidManifest.xml` المرفق — أو ابدأ من نسخة Flutter جديدة والصق مجلد `lib/`.

---

## 📁 بنية المشروع — Project Structure

```
al-muazzen-flutter/
├── pubspec.yaml
├── analysis_options.yaml
├── LICENSE                  # MIT + Rafeeq attribution
├── README.md
├── PRIVACY_POLICY.md        # سياسة الخصوصية (عربي+إنجليزي) — لازمة لـ Play
├── PLAY_STORE.md            # قائمة نشر Play كاملة + نص إقرار المنبّه الدقيق
├── android/
│   ├── app/build.gradle     # compile/target SDK 36، minSdk 24، توقيع من key.properties
│   ├── key.properties.example  # نموذج مفتاح الرفع (لا مفاتيح حقيقية في المشروع)
│   └── app/src/main/AndroidManifest.xml  # أذونات دنيا مشروحة + Boot receiver
├── lib/
│   ├── main.dart            # الجذر: ثيم زمردي، عربي/RTL، تنقّل سفلي (5 تبويبات)
│   ├── widgets/
│   │   └── master_switch.dart  # المفتاح الرئيسي الكبير + منطق ON/OFF
│   ├── data/
│   │   ├── cities.dart      # 25 مدينة عربية بإحداثياتها
│   │   └── azkar.dart       # أذكار الصباح (10) والمساء (10) بالمصادر
│   ├── services/
│   │   ├── prayer_service.dart       # adhan: المواقيت، التالية/الحالية، القبلة
│   │   ├── settings_service.dart     # SharedPreferences
│   │   └── notification_service.dart # إشعارات محلية مجدولة لكل صلاة
│   └── screens/
│       ├── home_screen.dart      # مفتاح رئيسي + صامت مؤقتاً + هجري + عدّاد حي
│       ├── azkar_screen.dart     # تبويبا صباح/مساء بعدّادات
│       ├── tasbih_screen.dart    # سبحة دائرية 33/99/100
│       ├── qibla_screen.dart     # زاوية القبلة + بوصلة مرسومة
│       ├── privacy_screen.dart   # سياسة الخصوصية داخل التطبيق (متطلب Play)
│       └── settings_screen.dart  # مفتاح رئيسي، مدينة، طريقة، مذهب، إشعارات، ليلي، خصوصية
└── test/
    ├── prayer_service_test.dart  # ترتيب الصلوات، القبلة، الطرق، التالية
    └── settings_test.dart        # المفتاح الرئيسي + الكتم المؤقت
```

التنقّل السفلي: **الصلاة 🏠 | الأذكار 📖 | السبحة | القبلة 🧭 | الإعدادات ⚙️**

---

## 🙏 الاعتمادات — Credits

- **Rafeeq** — https://github.com/teamsazen/Rafeeq — MIT License.
  Architecture inspiration (adhan + geolocator). Thank you to its contributors.
- **adhan** Dart package (Batoul Apps / adhan community) — prayer calculations.
- **hijri**, **flutter_local_notifications**, **timezone**, **geolocator**,
  **shared_preferences**, **intl** — their respective open-source licenses.
- أذكار الصباح والمساء: من حصن المسلم، بالمصادر مذكورة داخل التطبيق لكل ذِكر.

## 📄 الترخيص — License

MIT — انظر `LICENSE`. Holder: Al-Muazzen contributors, with Rafeeq MIT attribution retained.
