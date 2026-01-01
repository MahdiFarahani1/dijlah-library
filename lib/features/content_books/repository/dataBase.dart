import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class BookDatabaseHelper {
  static final BookDatabaseHelper _instance = BookDatabaseHelper._internal();
  factory BookDatabaseHelper() => _instance;
  BookDatabaseHelper._internal();

  Database? _database;
  String? _currentBookId;
  static bool _ffiInitialized = false;
  Future<void> inspectBookZip(String id) async {
    final basePath = (await getBaseBooksDir()).path;
    final zipFile = File(p.join(basePath, 'book_${id}_db.zip')); // اسم واقعی

    if (!await zipFile.exists()) {
      print('❌ ZIP file not found.');
      return;
    }

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    print('📂 ZIP contains ${archive.length} files:');
    for (final file in archive) {
      print('   • ${file.name} (${file.isFile ? "file" : "dir"})');
    }
  }

  Future<Directory> getBaseBooksDir() async {
    if (Platform.isAndroid) {
      final dir = await getApplicationDocumentsDirectory() ??
          await getApplicationDocumentsDirectory();
      return Directory(p.join(dir.path, 'Books'));
    }

    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return Directory(p.join(dir.path, 'Books'));
    }
    // Windows/macOS/Linux
    final dir = await getApplicationSupportDirectory();
    return Directory(p.join(dir.path, 'Books'));
  }

  Future<String> _zipPath(String id) async {
    final base = await getBaseBooksDir();
    return p.join(base.path, 'book_${id}_db.zip');
  }

  Future<String> _extractDir(String id) async {
    final base = await getBaseBooksDir();
    final tmp = Directory(p.join(base.path, 'tmp', id));
    // Ensure tmp directory exists
    if (!await tmp.exists()) {
      await tmp.create(recursive: true);
    }
    return tmp.path;
  }

  Future<String> _dbFilePath(String id) async {
    final dir = await _extractDir(id);
    return p.join(dir, 'book_${id}_db.sqlite');
  }

  Future<String> _extractDatabaseFromZip(String id) async {
    try {
      final zipFile = File(await _zipPath(id));
      if (!await zipFile.exists()) {
        throw Exception('📦 فایل ZIP کتاب یافت نشد!');
      }

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final outputDir = await _extractDir(id);

      for (final file in archive) {
        final filename = file.name;
        final outPath = p.join(outputDir, filename);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      final dbPath = await _dbFilePath(id);
      if (!await File(dbPath).exists()) {
        throw Exception('❌ فایل دیتابیس داخل زیپ پیدا نشد!');
      }

      return dbPath;
    } catch (e) {
      print('❌ Error extracting database: $e');
      rethrow;
    }
  }

  /// فقط یکبار دیتابیس باز میشه، اگه همون کتاب قبلاً باز شده، دوباره باز نمیشه
  Future<void> openDatabaseForBook(String id) async {
    try {
      if (_database != null && _currentBookId == id) {
        // دیتابیس از قبل برای همین کتاب باز شده
        return;
      }

      // بستن دیتابیس قبلی اگه وجود داشت
      await close();

      // Desktop: init FFI only once
      if (!_ffiInitialized &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        try {
          ffi.sqfliteFfiInit();
          databaseFactory = ffi.databaseFactoryFfi;
          _ffiInitialized = true;
          print('✅ FFI initialized successfully');
        } catch (e) {
          print('❌ Error initializing FFI: $e');
          // Fallback to default database factory
          print('⚠️ Using default database factory');
        }
      }

      final dbPath = await _extractDatabaseFromZip(id);
      print('📁 Opening database at: $dbPath');
      _database = await openDatabase(dbPath);
      _currentBookId = id;
      print('✅ Database opened successfully');
    } catch (e) {
      print('❌ Error opening database: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBookPages(String bookId) async {
    if (_database == null) {
      throw Exception('❌ دیتابیس هنوز باز نشده است!');
    }
    try {
      final result =
          await _database!.query('b${bookId}_pages', orderBy: 'id ASC');
      return result;
    } catch (e) {
      print('❌ Error querying pages: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBookGroup(String bookId) async {
    if (_database == null) {
      throw Exception('❌ دیتابیس هنوز باز نشده است!');
    }
    try {
      final result =
          await _database!.query('b${bookId}_chapters', orderBy: 'id ASC');
      return result;
    } catch (e) {
      print('❌ Error querying groups: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      _currentBookId = null;
      print('✅ Database closed successfully');
    } catch (e) {
      print('❌ Error closing database: $e');
    }
  }
}
