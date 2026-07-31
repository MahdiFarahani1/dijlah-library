# # 📚 Dijlah Library | مكتبة دجلة

اپلیکیشن **Dijlah Library** یک کتابخانه دیجیتال و کتابخوان حرفه‌ای است که با Flutter توسعه داده شده است.

این برنامه امکان دسترسی به مجموعه‌ای از کتاب‌های دیجیتال، مطالعه آفلاین، مدیریت نشانک‌ها، ثبت یادداشت‌ها، پیگیری میزان مطالعه و مشاهده محتوای چندرسانه‌ای را فراهم می‌کند.

تمرکز اصلی این پروژه روی **تجربه مطالعه آفلاین، عملکرد بالا، معماری قابل توسعه و پشتیبانی از پلتفرم‌های مختلف** بوده است.

---

# 📱 دانلود

نسخه منتشرشده اپلیکیشن:

🔗 Google Play:
[لینک اپلیکیشن در Google Play]

---

# ✨ امکانات اصلی

## 📖 کتابخانه دیجیتال

* مشاهده لیست کتاب‌ها
* دسته‌بندی و جستجو بین محتوا
* دانلود کتاب‌ها برای استفاده آفلاین
* مدیریت کتاب‌های دانلود شده

## 📚 کتابخوان آفلاین

* مطالعه کتاب بدون نیاز به اینترنت
* ذخیره دیتابیس هر کتاب به صورت جداگانه
* نمایش محتوای HTML کتاب‌ها
* تغییر اندازه فونت
* پشتیبانی از مطالعه طولانی مدت

## 🔖 امکانات مطالعه

* افزودن صفحات به علاقه‌مندی‌ها
* ذخیره یادداشت‌ها و نظرات
* ذخیره آخرین موقعیت مطالعه
* ادامه مطالعه از آخرین صفحه

## 🎨 تجربه کاربری

* پشتیبانی کامل از زبان عربی و RTL
* حالت تاریک و روشن
* طراحی Responsive
* انیمیشن‌های UI
* Loading Skeleton
* کامپوننت‌های قابل استفاده مجدد

## 🔔 امکانات دیگر

* Push Notification
* اشتراک‌گذاری محتوا
* مدیریت تنظیمات کاربر
* پشتیبانی از Android، iOS و Desktop

---

# 🏗️ معماری پروژه

پروژه با معماری:

## Feature First BLoC/Cubit Architecture

طراحی شده است.

در این ساختار هر قابلیت به صورت مستقل مدیریت می‌شود و شامل منطق، UI و دسترسی به داده‌های مربوط به خود است.

مزایای این معماری:

* توسعه آسان‌تر قابلیت‌های جدید
* جداسازی مسئولیت‌ها
* نگهداری ساده‌تر کد
* کاهش وابستگی بین بخش‌ها

ساختار کلی:

```text
lib/
│
├── config/
│
├── core/
│
├── shared/
│
├── features/
│   │
│   ├── books/
│   ├── content_books/
│   ├── search/
│   ├── storage/
│   ├── settings/
│   ├── reading_progress/
│   ├── mainWrapper/
│   └── about/
│
└── main.dart
```

---

# 🛠️ تکنولوژی‌ها و ابزارها

## Framework

* Flutter
* Dart

## State Management

* BLoC
* Cubit
* flutter_bloc
* Hydrated Bloc

## Networking

* Dio
* HTTP

## Database & Storage

* SQLite
* sqflite
* sqflite_common_ffi
* GetStorage
* Path Provider

## Media & Content

* Video Player
* Just Audio
* HTML Rendering

## Dependency Management

* GetIt

## Firebase

* Firebase Core
* Firebase Messaging
* Local Notifications

## UI / UX

* Cached Network Image
* Flutter Animate
* Skeletonizer
* Lottie
* Flutter SVG
* Google Fonts

---

# ⚡ سیستم آفلاین کتاب‌ها

یکی از بخش‌های مهم این پروژه، سیستم مدیریت دیتابیس آفلاین کتاب‌ها است.

فرآیند کار:

```text
Download Book Package
        |
        ↓
ZIP Extraction
        |
        ↓
SQLite Database Creation
        |
        ↓
Offline Reading Engine
```

هر کتاب دیتابیس SQLite اختصاصی خود را دارد که باعث:

* سرعت بالاتر مطالعه
* کاهش مصرف اینترنت
* تجربه آفلاین واقعی

می‌شود.

---

# 🗄️ مدیریت داده‌ها

پروژه از ترکیبی از ذخیره‌سازی‌ها استفاده می‌کند:

### SQLite

برای:

* اطلاعات کتاب‌ها
* صفحات کتاب
* نشانک‌ها
* یادداشت‌ها
* پیشرفت مطالعه

### GetStorage

برای:

* تنظیمات کاربر
* وضعیت اولیه برنامه
* تنظیمات مطالعه

---

# 🎨 رابط کاربری

ویژگی‌های UI:

* طراحی مخصوص زبان عربی
* پشتیبانی RTL
* فونت اختصاصی
* Theme روشن و تاریک
* Widgetهای قابل استفاده مجدد
* مدیریت Loading و Error State

---

# 🚀 بهینه‌سازی عملکرد

برای بهبود Performance:

* ذخیره محتوای کتاب به صورت Local Database
* Cache تصاویر
* Pagination برای لیست‌ها
* مدیریت بهینه State
* جلوگیری از دانلودهای غیرضروری

---

# 🔌 مدیریت State

بخش‌های مختلف برنامه توسط Cubit مدیریت می‌شوند:

نمونه‌ها:

* BookCubit
* DownloadCubit
* SearchCubit
* BookmarkCubit
* SettingsCubit
* ReadingProgressCubit

---

# 🔐 امنیت

اطلاعات حساس پروژه مانند:

* کلیدهای خصوصی
* تنظیمات محیط توسعه
* اطلاعات Backend

نباید در Repository عمومی قرار بگیرند.

---

# ⚙️ اجرای پروژه

پیش‌نیاز:

* Flutter SDK
* Dart SDK

دریافت وابستگی‌ها:

```bash
flutter pub get
```

اجرای پروژه:

```bash
flutter run
```

---

# 👨‍💻 درباره پروژه

Dijlah Library یک پروژه Flutter در سطح Production است که با تمرکز روی ساخت یک سیستم کتابخانه دیجیتال آفلاین، مدیریت محتوای بزرگ و تجربه مطالعه روان توسعه داده شده است.

این پروژه نمونه‌ای از توسعه یک اپلیکیشن واقعی با:

* Flutter
* BLoC/Cubit
* SQLite
* سیستم Sync آفلاین
* معماری Feature First

است.

---

# ⭐ نقاط قوت پروژه

⭐ سیستم کتابخوان آفلاین مبتنی بر SQLite
⭐ پشتیبانی چند پلتفرمی
⭐ معماری Feature First
⭐ مدیریت State با BLoC/Cubit
⭐ طراحی RTL عربی
⭐ مدیریت Bookmark و Reading Progress
⭐ سیستم دانلود و استخراج دیتابیس کتاب‌ها
⭐ تجربه کاربری Production-Level
