import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bookapp/features/search/bloc/search_cubit.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:bookapp/shared/func/folder_check.dart';

class SearchRepository {
  // Keep track of open database connections
  static final Map<String, Database> _openDatabases = {};

  static Future<List<File>> _listSqliteFilesRecursively(Directory dir) async {
    List<File> files = [];

    final entities = dir.listSync(recursive: true, followLinks: false);
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('.sqlite')) {
        files.add(entity);
      }
    }

    return files;
  }

  // Get or create database connection
  static Future<Database> _getDatabase(String filePath) async {
    if (_openDatabases.containsKey(filePath)) {
      final db = _openDatabases[filePath]!;
      // Check if database is still open
      try {
        await db.rawQuery('SELECT 1');
        return db;
      } catch (e) {
        // Database is closed, remove it and create new one
        print('Database $filePath is closed, removing from cache');
        _openDatabases.remove(filePath);
      }
    }

    try {
      // Ensure desktop DB factory on non-mobile
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        ffi.sqfliteFfiInit();
        databaseFactory = ffi.databaseFactoryFfi;
      }
      final db = await databaseFactory.openDatabase(filePath);
      _openDatabases[filePath] = db;
      print('Opened database: $filePath');
      return db;
    } catch (e) {
      print('Error opening database $filePath: $e');
      rethrow;
    }
  }

  // Close all open databases
  static Future<void> closeAllDatabases() async {
    print('Closing ${_openDatabases.length} open databases');
    for (final entry in _openDatabases.entries) {
      try {
        final db = entry.value;
        await db.close();
        print('Closed database: ${entry.key}');
      } catch (e) {
        print('Error closing database ${entry.key}: $e');
      }
    }
    _openDatabases.clear();
    print('All databases closed');
  }

  static Future<List<SearchResultItem>> searchInAllBooks(String query) async {
    print('🔍 Starting search in all books for query: $query');
    final base = await getBooksBaseDir();
    final dir = Directory(p.join(base.path, 'tmp'));

    if (!await dir.exists()) {
      print('❌ Books directory does not exist: ${dir.path}');
      return [];
    }

    final dbFiles = await _listSqliteFilesRecursively(dir);
    print('✅ Found ${dbFiles.length} .sqlite databases in ${dir.path}');

    List<SearchResultItem> results = [];

    for (var file in dbFiles) {
      try {
        print('📘 Searching in database: ${file.path}');
        final db = await _getDatabase(file.path);

        // استخراج bookId از نام فایل مثل book_22_db.sqlite
        final rawName = p.basenameWithoutExtension(file.path);
        final RegExpMatch? match = RegExp(r'book_(\d+)_db').firstMatch(rawName);
        if (match == null) {
          print('⚠️ Invalid database name format: $rawName');
          continue;
        }

        final String bookId = match.group(1)!;

        final res = await db.rawQuery(
          "SELECT page, _text FROM b${bookId}_pages WHERE _text LIKE ?",
          ['%$query%'],
        );

        print('🔸 Found ${res.length} results in book $bookId');
        for (var row in res) {
          results.add(SearchResultItem(
            pageNumber: row['page'] as dynamic,
            text: row['_text'] as String,
            bookName: bookId,
            bookId: bookId,
          ));
        }
      } catch (e) {
        print('❌ Error searching in database ${file.path}: $e');
        _openDatabases.remove(file.path); // حذف دیتابیس مشکل‌دار از کش
      }
    }

    print('✅ Total search results: ${results.length}');
    return results;
  }

  static Future<List<SearchResultItem>> advancedSearch({
    required String query,
    required bool searchText,
    required bool searchTitle,
    required String bookPath, // "all" or specific path
  }) async {
    print('🔍 Starting advanced search for "$query"');
    print(
        '🧩 Options: text=$searchText, title=$searchTitle, bookPath=$bookPath');

    final List<File> dbFiles;
    if (bookPath == "all") {
      final base = await getBooksBaseDir();
      final rootDir = Directory(p.join(base.path, 'tmp'));
      if (!await rootDir.exists()) {
        print('❌ Books directory does not exist: ${rootDir.path}');
        return [];
      }
      dbFiles = await _listSqliteFilesRecursively(rootDir);
    } else {
      final file = File(bookPath);
      if (!await file.exists()) {
        print('❌ Book file does not exist: $bookPath');
        return [];
      }
      dbFiles = [file];
    }

    print('✅ Found ${dbFiles.length} databases to search');

    List<SearchResultItem> results = [];

    for (var file in dbFiles) {
      try {
        print('📘 Searching in database: ${file.path}');
        final db = await _getDatabase(file.path);

        // استخراج bookId صحیح از نام فایل
        final rawName = p.basenameWithoutExtension(file.path);
        final RegExpMatch? match = RegExp(r'book_(\d+)_db').firstMatch(rawName);
        if (match == null) {
          print('⚠️ Invalid database name format: $rawName');
          continue;
        }

        final String bookId = match.group(1)!;

        if (searchText) {
          final res = await db.rawQuery(
            "SELECT page, _text FROM b${bookId}_pages WHERE _text LIKE ?",
            ['%$query%'],
          );
          print('🔹 Found ${res.length} text results in book $bookId');
          for (var row in res) {
            results.add(SearchResultItem(
              pageNumber: row['page'] as dynamic,
              text: row['_text'] as String,
              bookName: bookId,
              bookId: bookId,
            ));
          }
        }

        if (searchTitle) {
          final res = await db.rawQuery(
            "SELECT page, title FROM b${bookId}_chapters WHERE title LIKE ?",
            ['%$query%'],
          );
          print('🔹 Found ${res.length} title results in book $bookId');
          for (var row in res) {
            results.add(SearchResultItem(
              pageNumber: row['page'] as dynamic,
              text: row['title'] as String,
              bookName: bookId,
              bookId: bookId,
            ));
          }
        }
      } catch (e) {
        print('❌ Error searching in database ${file.path}: $e');
        _openDatabases.remove(file.path);
      }
    }

    print('✅ Total advanced search results: ${results.length}');
    return results;
  }
}
