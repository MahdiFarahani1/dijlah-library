import 'package:get_storage/get_storage.dart';

class DownloadProgressStorage {
  static final _box = GetStorage();

  static const _totalBooksKey = 'total_books';
  static const _downloadedBooksKey = 'downloaded_books';

  /// ذخیره تعداد کل کتاب‌ها
  static void setTotalBooks(int total) {
    _box.write(_totalBooksKey, total);
  }

  /// ذخیره تعداد کتاب‌های دانلود شده
  static void setDownloadedBooks(int downloaded) {
    _box.write(_downloadedBooksKey, downloaded);
  }

  /// خواندن تعداد کل کتاب‌ها
  static int getTotalBooks() {
    return _box.read(_totalBooksKey) ?? 0;
  }

  /// خواندن تعداد کتاب‌های دانلود شده
  static int getDownloadedBooks() {
    return _box.read(_downloadedBooksKey) ?? 0;
  }

  /// درصد دانلود شده
  static double getProgress() {
    final total = getTotalBooks();
    if (total == 0) return 0;
    return getDownloadedBooks() / total;
  }
}
