# Store Assets — أصول المتجر

- `play-store-icon-512.png` — أيقونة Google Play الرسمية: 512×512 PNG (أقل من 1MB) — تُرفع في Play Console.
- `icon-master-1024.png` — النسخة الرئيسية 1024×1024 (نفسها في `assets/icon/icon.png`).
- `adaptive-foreground-1024.png` — مقدمة الأيقونة التكيفية (شفافة) 1024×1024.
- `adaptive-preview.png` — معاينة الأيقونة التكيفية على خلفيتها الزمردية #065F46.

داخل التطبيق نفسه، الأيقونة مثبّتة في:
`android/app/src/main/res/mipmap-*` (ic_launcher + round + foreground بكل الكثافات)
و `mipmap-anydpi-v26/ic_launcher.xml` (Adaptive Icon) و `values/colors.xml` (لون الخلفية).
- `feature-graphic-1024x500.png` — الصورة الرئيسية لصفحة المتجر: 1024×500 PNG بالهوية نفسها مع اسم التطبيق.
- `screenshots/` — لقطات شاشة حقيقية من التطبيق نفسه (نسخة الويب بنفس الكود): 5 لقطات 1080×1920 PNG ‏(الصلاة، الأذكار، السبحة، القبلة، الإعدادات) — جاهزة للرفع في Play Console.
