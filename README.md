# 🚚 سوق الشاحنات - Truck Market App

تطبيق أندرويد كامل لبيع وشراء الشاحنات، مبني بـ Flutter مع Supabase كقاعدة بيانات حقيقية.

---

## 📱 مميزات التطبيق

- **تسجيل دخول وإنشاء حساب** (بريد إلكتروني + كلمة مرور)
- **نوعان من الحسابات**: تاجر (بائع) أو مشتري
- **الصفحة الرئيسية**: عرض جميع إعلانات الشاحنات
- **فلترة وبحث**: حسب النوع، المدينة، الحالة
- **إضافة إعلانات**: للتجار فقط مع صور
- **تفاصيل الإعلان**: كامل المعلومات + الاتصال بالبائع
- **واتساب وهاتف**: للتواصل المباشر مع البائع
- **إدارة الإعلانات**: عرض وحذف إعلاناتي

---

## 🔧 خطوات التشغيل

### الخطوة 1: إعداد Supabase (مجاني)

1. اذهب إلى [supabase.com](https://supabase.com) وأنشئ حساباً مجانياً
2. أنشئ **Project** جديد
3. اذهب إلى **SQL Editor** وانسخ محتوى ملف `supabase_setup.sql` والصقه ونفذه
4. اذهب إلى **Project Settings > API** وانسخ:
   - `Project URL` → ضعه في `lib/main.dart`
   - `anon public key` → ضعه في `lib/main.dart`

### الخطوة 2: تحديث الإعدادات

افتح `lib/main.dart` وعدل:
```dart
await Supabase.initialize(
  url: 'https://XXXXXXX.supabase.co',  // ← URL المشروع
  anonKey: 'eyJhbGci...',               // ← anon key
);
```

### الخطوة 3: تثبيت Flutter

```bash
# تحميل Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# التحقق من التثبيت
flutter doctor
```

### الخطوة 4: تشغيل التطبيق

```bash
# الانتقال لمجلد المشروع
cd truck_market

# تثبيت المكتبات
flutter pub get

# تشغيل على محاكي أو جهاز
flutter run

# أو بناء APK
flutter build apk --release
```

---

## 📁 هيكل المشروع

```
truck_market/
├── lib/
│   ├── main.dart                    # نقطة البداية
│   ├── models/
│   │   ├── user_model.dart          # نموذج المستخدم
│   │   └── truck_listing.dart       # نموذج الإعلان
│   ├── services/
│   │   ├── auth_service.dart        # خدمة المصادقة
│   │   └── listing_service.dart     # خدمة الإعلانات
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── splash_screen.dart   # شاشة البداية
│   │   │   ├── login_screen.dart    # تسجيل الدخول
│   │   │   └── register_screen.dart # إنشاء حساب
│   │   ├── common/
│   │   │   ├── home_screen.dart     # الشاشة الرئيسية
│   │   │   ├── listings_screen.dart # قائمة الإعلانات
│   │   │   ├── listing_detail_screen.dart # تفاصيل إعلان
│   │   │   └── profile_screen.dart  # الملف الشخصي
│   │   └── seller/
│   │       ├── add_listing_screen.dart    # إضافة إعلان
│   │       └── my_listings_screen.dart   # إعلاناتي
│   ├── widgets/
│   │   └── listing_card.dart        # بطاقة الإعلان
│   └── utils/
│       └── app_theme.dart           # ثيم التطبيق
├── android/                         # ملفات أندرويد
├── supabase_setup.sql               # إعداد قاعدة البيانات
└── pubspec.yaml                     # المكتبات
```

---

## 🛠️ المكتبات المستخدمة

| المكتبة | الاستخدام |
|---------|-----------|
| `supabase_flutter` | قاعدة البيانات والمصادقة |
| `image_picker` | اختيار صور من الجهاز |
| `cached_network_image` | تحميل الصور من الإنترنت |
| `timeago` | عرض الوقت بالعربية |
| `url_launcher` | فتح الهاتف والواتساب |
| `intl` | تنسيق التواريخ |

---

## 📞 التواصل مع البائع

- **زر الاتصال**: يفتح تطبيق الهاتف مباشرة
- **زر واتساب**: يفتح محادثة واتساب مع رسالة جاهزة

---

## 🌐 Supabase Dashboard

بعد التشغيل يمكنك مراقبة:
- **Authentication**: قائمة المستخدمين المسجلين
- **Table Editor**: بيانات الإعلانات
- **Storage**: صور الشاحنات

---

صُنع بـ ❤️ لسوق الشاحنات العربي
