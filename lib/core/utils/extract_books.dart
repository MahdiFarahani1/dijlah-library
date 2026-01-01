import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:bookapp/shared/func/folder_check.dart';
import 'package:path/path.dart' as p;

Future<void> extractBookSqlite(String bookId) async {
  final base = await getBooksBaseDir();
  final booksPath = base.path;

  final zipFile = File('$booksPath/book_${bookId}_db.zip');
  if (!zipFile.existsSync()) {
    print('❌ ZIP not found for book $bookId');
    return;
  }

  final mainSqlite = File('$booksPath/book_${bookId}_db.sqlite');
  final tmpSqlite = File('$booksPath/tmp/$bookId/book_${bookId}_db.sqlite');

  // اگر قبلاً اکسترکت شده → هیچی نکن
  if (mainSqlite.existsSync() || tmpSqlite.existsSync()) {
    print('⏭ Book $bookId already extracted, skipping...');
    return;
  }

  print('📦 Extracting ZIP for book $bookId ...');

  try {
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final f in archive) {
      if (f.isFile && f.name.endsWith('.sqlite')) {
        final outPath = '$booksPath/tmp/$bookId/${p.basename(f.name)}';
        File(outPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(f.content as List<int>);
      }
    }

    if (tmpSqlite.existsSync()) {
      print('✅ Extracted sqlite for book $bookId');
    } else {
      print('❌ Extract failed: sqlite not found');
    }
  } catch (e) {
    print('❌ ZIP extract error: $e');
  }
}
