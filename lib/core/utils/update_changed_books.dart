import 'dart:io';

import 'package:bookapp/core/constant/const_class.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/features/books/widgets/file_downloader.dart';
import 'package:bookapp/shared/func/folder_check.dart';

Future<void> checkAndUpdateChangedBooks(List<BookModel> books) async {
  final baseDir = await getBooksBaseDir();

  for (final book in books) {
    final bookId = book.id.toString();

    if (book.changedPages == 1) {
      // مسیر فایل SQLite و ZIP
      final sqliteFile = File('${baseDir.path}/book_${bookId}_db.sqlite');
      final zipFile = File('${baseDir.path}/book_${bookId}_db.zip');

      // فقط اگر قبلاً دانلود شده بودن (SQLite یا ZIP موجود بود)
      if (await sqliteFile.exists() || await zipFile.exists()) {
        // پاک کردن SQLite
        if (await sqliteFile.exists()) {
          await sqliteFile.delete();
          print('🗑️ Deleted sqlite for book $bookId');
        }

        // پاک کردن ZIP
        if (await zipFile.exists()) {
          await zipFile.delete();
          print('🗑️ Deleted ZIP for book $bookId');
        }

        // دانلود دوباره
        await FileDownloader.downloadFile(
          url: ConstantApp.downloadBook + bookId,
          customDirectoryPath: baseDir.path,
          onProgress: (progress) {
            print('📊 Progress for $bookId: $progress%');
          },
          onComplete: (filePath) {
            print('✅ Download completed for $bookId');
            print('📁 File saved at: $filePath');
          },
        );

        print('⬇️ Book $bookId re-downloaded because changed_pages == 1');
      } else {
        print(
            '⚠️ Book $bookId has changed_pages == 1 but was not downloaded before → skipping');
      }
    } else {
      print('Book $bookId has no changes → skipping');
    }
  }
}
