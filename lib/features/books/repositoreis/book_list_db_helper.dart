import 'dart:io';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class BookListDbHelper {
  static Database? _database;
  static const String dbName = "booklist.sqlite";

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    // اگه فایل هنوز وجود نداشت، از assets کپی کن
    if (!File(path).existsSync()) {
      ByteData data = await rootBundle.load('assets/database/$dbName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path, readOnly: false, version: 2);
  }

  // --- Categories (bookgroups) ---

  static Future<void> insertCategories(List<CategoryModel> categories) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('bookgroups'); // Clear old data
      for (var cat in categories) {
        await txn.insert(
          'bookgroups',
          {
            'id': cat.id,
            'name': cat.title,
            'book_count': cat.booksCount,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookgroups');

    return maps.map((e) {
      return CategoryModel(
        id: e['id'] as int,
        title: e['name'] as String? ?? '',
        slug: '',
        booksCount: e['book_count'] as int? ?? 0,
      );
    }).toList();
  }

  // --- Books ---

  static Future<void> insertBooks(List<BookModel> books) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var book in books) {
        await txn.insert(
          'books',
          {
            'id': book.id,
            'gid': book.categoryId,
            'title': book.title,
            'writer': book.writerName,
            'img': book.photoUrl,
            'description': book.description ?? '',
            'page_number': book.numberPages,
            'category_name': book.category.title ?? 'null',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // فانکشن جدید برای اضافه یا آپدیت یک کتاب
  static Future<void> upsertBook(BookModel book) async {
    final db = await database;
    await db.insert(
      'books',
      {
        'id': book.id,
        'gid': book.categoryId,
        'title': book.title,
        'writer': book.writerName,
        'img': book.photoUrl,
        'description': book.description ?? '',
        'page_number': book.numberPages,
        'category_name': book.category.title ?? 'null',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<BookModel>> getBooks({int? categoryId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (categoryId != null) {
      maps = await db.query('books', where: 'gid = ?', whereArgs: [categoryId]);
    } else {
      maps = await db.query('books');
    }

    return maps.map((e) {
      return BookModel(
        id: e['id'] as int,
        categoryId: e['gid'] as int? ?? 0,
        title: e['title'] as String? ?? '',
        writerName: e['writer'] as String? ?? '',
        photoUrl: e['img'] as String? ?? '',
        description: e['description'] as String?,
        part: 0,
        dateTime: 0,
        updatedAt: '',
        idShow: 0,
        bookCode: '',
        internationalNumber: 0,
        changedPages: 0,
        pdfLink: '',
        epubLink: '',
        soundUrl: '',
        scholarName: '',
        numberPages: e['page_number'],
        category: CategoryModel(
            id: e['gid'] as int? ?? 0,
            title: e['category_name'] as String? ?? 'بدون دسته‌بندی',
            slug: '',
            booksCount: 0),
      );
    }).toList();
  }

  static Future<bool> hasData() async {
    final db = await database;
    try {
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM books'));
      return (count ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> doesBookExist(int id) async {
    final db = await database;
    try {
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM books WHERE id = ?', [id]));
      return (count ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  // --- Update (Sync) ---

  static Future<String> getLastUpdate() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('update');
      if (maps.isNotEmpty) {
        return maps.first['update'] as String? ?? '';
      }
      return '';
    } catch (e) {
      print('⚠️ Error getting last update: $e');
      return '';
    }
  }

  static Future<void> setLastUpdate(String val) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('update');
      await txn.insert('update', {'update': val});
    });
  }
}
