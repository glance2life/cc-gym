# cc-gym

[English](README.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [Русский](README.ru.md) | [한국어](README.ko.md) | العربية

أثناء انشغال Claude Code بالعمل، يخرجك cc-gym من حالة "التحديق في الشاشة" ويدفعك لتمرين قصير من 30 ثانية.

ملاحظات التصميم: [DESIGN.md](./DESIGN.md) (بالصينية).

## التثبيت

داخل Claude Code:

```
/plugin marketplace add glance2life/cc-gym
/plugin install cc-gym@cc-gym
```

(يقبل `marketplace add` الصيغة المختصرة `owner/repo`؛ كما يصلح الرابط الكامل `https://github.com/glance2life/cc-gym`. **لا حاجة إلى fork** — هي عملية جلب للقراءة فقط.)

بعد التثبيت، أعد التشغيل أو نفّذ `/reload-plugins` لتفعيل الـ hooks.

## التحديث / الإزالة

لا يجلب Claude Code الإصدارات الجديدة تلقائيًا. خطوتان يدويتان:

```
/plugin marketplace update cc-gym     # جلب أحدث commit من الـ marketplace
/plugin update cc-gym@cc-gym          # تحديث الإضافة نفسها
```

ثم أعد التشغيل أو نفّذ `/reload-plugins`. للإزالة:

```
/plugin uninstall cc-gym@cc-gym
```

## الإعدادات

كل الإعدادات عبر متغيرات البيئة، لا توجد واجهة رسومية. القيم الافتراضية مناسبة، عدّل ما تحتاجه فقط:

| المتغير | الافتراضي | الوظيفة |
|---|---|---|
| `CC_GYM_LIGHT_SEC` | `20` | الثواني قبل أول تذكير (خفيف) |
| `CC_GYM_HEAVY_SEC` | `180` | الثواني قبل التصعيد إلى تذكير قوي |
| `CC_GYM_GLOBAL_COOLDOWN` | `900` (15 دقيقة) | الحد الأدنى للفاصل بين أي تذكيرَين عبر كل الجلسات |
| `CC_GYM_LANG` | تلقائي من `$LANG` | لغة الواجهة. المدعومة: `en`, `zh`, `es`, `ja`, `fr`, `de`, `pt`, `ru`, `ko`, `ar`. القيم غير المعروفة ترجع إلى `en` |
| `CC_GYM_LIGHT_FILE` | مدمج (حسب اللغة) | قائمة تمارين خفيفة مخصصة |
| `CC_GYM_HEAVY_FILE` | مدمج (حسب اللغة) | قائمة تمارين قوية مخصصة |

تنسيق القائمة: سطر واحد لكل عنصر، `category: التمرين`، `category ∈ {eye, neck, leg, breath}`، الأسطر التي تبدأ بـ `#` تعليقات.
