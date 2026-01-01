import 'dart:io';
import 'package:bookapp/core/constant/const_class.dart';
import 'package:bookapp/core/utils/extract_books.dart';
import 'package:bookapp/core/utils/getZip_Sqlite.dart';
import 'package:bookapp/features/books/bloc/download/download_cubit.dart';
import 'package:bookapp/features/books/bloc/downloaded_page/downloaded_page_cubit.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/features/books/repositoreis/book_list_db_helper.dart';
import 'package:bookapp/shared/func/folder_check.dart';

class SyncManager {
  static Future<void> syncBooks(
      List<BookModel> books, DownloadCubit downloadCubit, Function onRefresh,
      {bool isIncremental = false}) async {
    print(
        '🔄 [SyncManager] Processing ${books.length} updates (Incremental: $isIncremental)...');

    if (!isIncremental) {
      // Initial load: Insert all books
      await BookListDbHelper.insertBooks(books);
      print('✅ [Sync] Initial load completed: All books inserted.');
      return;
    }

    for (var book in books) {
      try {
        // 1. Check if book exists locally
        final exists = await BookListDbHelper.doesBookExist(book.id);
        if (!exists) {
          print('⚡ [Sync] Book ${book.id} not found locally, skipping.');
          continue;
        }

        final baseDir = await getBooksBaseDir();
        final zipFile = File('${baseDir.path}/book_${book.id}_db.zip');
        final sqliteFile =
            File('${baseDir.path}/tmp/${book.id}/book_${book.id}_db.sqlite');

        // 2. Only act if zip exists AND changedPages == 1
        if (book.changedPages == 1 && await zipFile.exists()) {
          print('♻️ [Sync] Book ${book.id} content changed. Updating...');

          // Delete old files
          if (await zipFile.exists()) {
            await zipFile.delete();
            print('🗑️ Deleted old zip: ${zipFile.path}');
          }
          if (await sqliteFile.exists()) {
            await sqliteFile.delete();
            print('🗑️ Deleted old sqlite: ${sqliteFile.path}');
          }

          // Start new download
          final url = '${ConstantApp.downloadBook}${book.id}';
          downloadCubit
              .startBookDownload(
            book.id.toString(),
            url,
          )
              .then((value) async {
            await extractBookSqlite(book.id.toString());
            onRefresh();
          });

          // Update DB
          await BookListDbHelper.insertBooks([book]);
          print('✅ [Sync] Book ${book.id} updated successfully.');
        } else {
          // Zip doesn't exist OR changedPages != 1 → do nothing
          print('⚡ [Sync] Book ${book.id} has no zip or no changes, skipping.');
        }
      } catch (e) {
        print('❌ [Sync] Error processing book ${book.id}: $e');
      }
    }
  }
}
