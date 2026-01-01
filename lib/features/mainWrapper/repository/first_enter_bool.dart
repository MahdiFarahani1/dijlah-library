import 'package:get_storage/get_storage.dart';

/// کلیدها رو با ثابت نگه داشتن، از اشتباهات تایپی جلوگیری می‌کنیم.
class EnterStorageService {
  // Singleton
  static final EnterStorageService _instance = EnterStorageService._internal();
  factory EnterStorageService() => _instance;
  EnterStorageService._internal();

  // شیء اصلی GetStorage
  final _box = GetStorage();

  // کلید ثابت برای مقدار ما
  static const String _keyMyBool = 'first_enter';

  /// 🔧 باید در ابتدای برنامه صدا زده بشه (مثلاً در main)

  /// 💾 ذخیره‌ی مقدار بولی
  Future<void> saveFirstEnter(bool value) async {
    await _box.write(_keyMyBool, value);
    print('✅ [STORAGE] مقدار ذخیره شد: $value');
  }

  /// 📖 خواندن مقدار بولی
  bool readFirstEnter() {
    final value = _box.read(_keyMyBool) ?? false;
    print('📤 [STORAGE] مقدار خوانده شد: $value');
    return value;
  }

  /// 🧼 (اختیاری) حذف مقدار ذخیره شده
  Future<void> clear() async {
    await _box.remove(_keyMyBool);
    print('🧽 [STORAGE] مقدار پاک شد');
  }
}
