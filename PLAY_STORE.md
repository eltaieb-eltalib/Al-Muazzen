# قائمة النشر على Google Play — المؤذن 🕌

> تحقّق منها بنداً بنداً قبل الرفع. مبنية على سياسات Play المُتحقق منها في نوفمبر 2026.

## 1) صيغة البناء والإصدار
- [ ] البناء للنشر بصيغة **AAB (Android App Bundle)** فقط:
  ```bash
  flutter build appbundle --release
  # الناتج: build/app/outputs/bundle/release/app-release.aab
  ```
- [ ] الـ **APK للاختبار المباشر فقط** (`flutter build apk --release`) — لا يُرفع على Play.
- [ ] `targetSdk = 36` و `compileSdk = 36` (Android 16) — **إلزامي للتطبيقات الجديدة منذ 31 أغسطس 2026** — مضبوط في `android/app/build.gradle`.
- [ ] `minSdk = 24`، `applicationId = com.tayeb.almuazzen`، `versionCode = 1`، `versionName = 1.0.0`.
- [ ] **Play App Signing مفعّلة:** Google تحتفظ بمفتاح التوقيع النهائي؛ أنت ترفع بمفتاح رفع (Upload Key) فقط.
- [ ] ملف `android/key.properties` محلي فقط وغير مرفوع على Git (انظر `key.properties.example` و`.gitignore`).

## 2) حساب المطوّر والاختبار المغلق
- [ ] حساب مطوّر Google Play: رسم لمرة واحدة **25 دولاراً**.
- [ ] للحسابات الشخصية الجديدة: **اختبار مغلق إلزامي — 12 مختبِراً على الأقل لمدة 14 يوماً** متواصلة قبل طلب الوصول للإنتاج.
- [ ] تجهيز قائمة بريد 12 مختبِراً مسبقاً (أصدقاء/عائلة) وتشغيل الاختبار من اليوم الأول.

## 3) إقرار سلامة البيانات (Data Safety) — إجابات هذا التطبيق
- [ ] **هل يجمع التطبيق بيانات؟ لا** — No data collected.
- [ ] **هل يشارك التطبيق بيانات؟ لا** — No data shared.
- [ ] الموقع: يُعالج على الجهاز فقط إن فعّله المستخدم، ولا يُجمع ولا يُشارك — لذلك لا يُصرّح عنه كبيانات مُجمّعة.
- [ ] لا بيانات مالية، لا جهات اتصال، لا رسائل، لا صور — لا شيء إطلاقاً.
- [ ] البيانات المحلية (الإعدادات) تبقى على الجهاز وتُحذف بإلغاء التثبيت.

## 4) التصنيفات والإقرارات
- [ ] **تقييم المحتوى (Content Rating):** أكمل استبيان IARC — التطبيق ديني/أدوات، بلا عنف أو محتوى حساس — النتيجة المتوقعة: الجميع.
- [ ] **الجمهور المستهدف: 13+** — التطبيق **غير مصمّم للأطفال** (Not designed for children) ولا يستهدفهم.
- [ ] **إقرار الإعلانات: التطبيق لا يحتوي على إعلانات** — No ads.
- [ ] **سياسة الخصوصية:** رابط عام لملف `PRIVACY_POLICY.md` في Play Console + النص نفسه داخل التطبيق (الإعدادات ← سياسة الخصوصية).
- [ ] التطبيق ليس تطبيق أخبار، وليس تطبيقاً حكومياً، ولا يدّعي أي صفة رسمية.

## 5) إقرار المنبّه الدقيق (Exact Alarm Declaration) — نص جاهز للصق في Play Console

> انسخ هذا النص كما هو في خانة تبرير إذن `SCHEDULE_EXACT_ALARM`:

```
Al-Muazzen is a prayer-time (adhan) alarm app. Its single core function is to
notify the user at the exact, astronomically calculated moment each of the
five daily prayers begins. Prayer times are precise to the minute and change
every day; a delay of even a few minutes defeats the purpose of the app.
Therefore the app uses SCHEDULE_EXACT_ALARM (granted by the user in system
settings) to schedule one exact alarm per prayer. The app has no other
alarm, timer, calendar, or reminder functionality, and exact alarms are
never used for ads, tracking, or any background work.
```

## 6) أصول المتجر (Store Assets) — المقاسات المطلوبة
- [ ] أيقونة التطبيق: **512×512 PNG** (32-bit، بلا شفافية في الخلفية الكاملة).
- [ ] صورة مميزة (Feature Graphic): **1024×500** PNG/JPG.
- [ ] لقطات هاتف: **على الأقل 2** (يُنصح بـ 4-5) — الرئيسية (العدّاد)، الأذكار، السبحة، القبلة، الإعدادات.
- [ ] عنوان قصير + وصف كامل بالعربية (وإنجليزية اختيارية) — بدون كلمات مضللة أو حشو كلمات مفتاحية.

## 7) الصوت والحقوق
- [x] **صوت الأذان بترخيص حر موثّق:** تسجيل «Azan.ogg» من Wikimedia Commons بصوت Andrewler، برخصة **CC BY-SA 4.0**، مع النسبة لصاحبه داخل التطبيق التزاماً بشروط الرخصة. (لا يُشترط أن يكون الصوت ملكية عامة.)
  - مصدر الصوت المستخدم فعلياً (حُسم بقرار المالك 2026-11-17): تسجيل «Azan.ogg» من Wikimedia Commons، بصوت **Andrewler**، رخصة **CC BY-SA 4.0** — https://commons.wikimedia.org/wiki/File:Azan.ogg — يُستخدم دون تعديل، والنسبة داخل التطبيق (الإعدادات) وفي `assets/audio/ATTRIBUTION.md`.
  - دُمج في النسخة 1.0.1+2: صوت قناة إشعارات `adhan_sound_channel` (res/raw/adhan.mp3) + معاينة داخل الإعدادات عبر audioplayers + مفتاح «تشغيل صوت الأذان».
  - تنبيه موثّق: مجموعة github.com/abodehq/Athan-MP3 **بلا ترخيص** (GitHub API: ‏`license: null`) — بُحثت وقرّر المالك عدم استخدامها.
- [ ] نصوص الأذكار: من «حصن المسلم» مع ذكر المصدر داخل التطبيق لكل ذِكر.

## 8) قبل الإرسال للمراجعة
- [ ] اختبار AAB من مسار الاختبار الداخلي على جهاز حقيقي: تشغيل/إيقاف المؤذن، صامت مؤقتاً، إعادة تشغيل الجهاز (تعود التنبيهات تلقائياً).
- [ ] لا Firebase، لا Analytics، لا Ads SDK — تأكد من `pubspec.yaml` و`build.gradle` (هذا المشروع نظيف افتراضياً).
- [ ] الأذونات في الـ Manifest هي الحد الأدنى فقط (انظر التعليقات داخل `AndroidManifest.xml`).
