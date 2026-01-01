import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:bookapp/shared/func/folder_check.dart';
import 'package:path/path.dart' as p;

Future<void> autoExtractMissingSqlites() async {
  final base = await getBooksBaseDir();
  final booksPath = base.path;

  final dir = Directory(booksPath);
  if (!dir.existsSync()) return;

  for (final file in dir.listSync()) {
    if (file is! File) continue;

    final filename = p.basename(file.path);
    final regex = RegExp(r"^book_(\d+)_db\.zip$");
    final match = regex.firstMatch(filename);
    if (match == null) continue;

    final bookId = match.group(1)!;

    final mainSqlite = File('$booksPath/book_${bookId}_db.sqlite');

    final tmpSqlite = File('$booksPath/tmp/$bookId/book_${bookId}_db.sqlite');

    // 1) اگر sqlite در مسیر اصلی وجود دارد → تمام
    if (mainSqlite.existsSync()) {
      continue;
    }

    // 2) اگر sqlite در TMP وجود دارد → باز هم ZIP را extract نکن
    if (tmpSqlite.existsSync()) {
      print("⏭ Book $bookId already extracted in TMP, skipping...");
      continue;
    }

    print("📦 Extracting ZIP for book $bookId ...");

    try {
      final bytes = file.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final f in archive) {
        if (f.isFile && f.name.endsWith('.sqlite')) {
          final outPath = '$booksPath/tmp/$bookId/${f.name}';
          File(outPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(f.content as List<int>);
        }
      }

      if (tmpSqlite.existsSync() || mainSqlite.existsSync()) {
        print("✅ Extracted sqlite for book $bookId");
      } else {
        print("❌ Extract failed: sqlite not found");
      }
    } catch (e) {
      print("❌ ZIP extract error: $e");
    }
  }
}
