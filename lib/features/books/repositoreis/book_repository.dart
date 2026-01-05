import 'dart:convert';
import 'package:bookapp/core/constant/const_class.dart';

import 'package:bookapp/features/books/model/model_books.dart';
import 'package:http/http.dart' as http;

class BookRepository {
  Future<List<CategoryModel>> fetchCategory() async {
    try {
      final res = await http.get(
        Uri.parse(ConstantApp.booksAPi),
        headers: {'x-api-key': ConstantApp.apiKey},
      );

      print('🟡 [DEBUG] Status Code: ${res.statusCode}');
      print('🟡 [DEBUG] Raw Response category: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data['categories'] == null) {
          print('⚠️ [WARNING] Response does not contain "category" key!');
          return [];
        }

        final category = (data['categories'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();

        return category;
      } else {
        print('❌ [ERROR] API returned status ${res.statusCode}');
        throw Exception('خطا در دریافت لیست کتاب‌ها: ${res.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🔥 [EXCEPTION] Error in fetchBooks: $e');
      print('📜 [STACKTRACE]\n$stackTrace');
      throw Exception('خطا در پردازش یا اتصال به سرور: $e');
    }
  }

  Future<LibraryResponse?> fetchLibrary({String? lastUpdate}) async {
    try {
      Uri uri = Uri.parse(ConstantApp.booksAPi);

      if (lastUpdate != null && lastUpdate.trim().isNotEmpty) {
        uri = uri.replace(queryParameters: {
          'last_update': lastUpdate,
        });
        print('🟡 [API CALL] Using last_update: $lastUpdate');
      } else {
        print('🟢 [API CALL] No last_update parameter, fetching all books');
      }

      print('🌐 [API CALL] URL: $uri');

      final res = await http.get(
        uri,
        headers: {'x-api-key': ConstantApp.apiKey},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        print('✅ [API] Successfully parsed response');
        return LibraryResponse.fromJson(data);
      } else {
        print('❌ [API] Error: ${res.statusCode}');
        throw Exception('API error: ${res.statusCode}');
      }
    } catch (e, s) {
      print('🔥 [EXCEPTION] fetchLibrary: $e');
      print('📜 [STACKTRACE] $s');
      rethrow;
    }
  }

  Future<LibraryResponse?> fetchCompaniesBooks(String apiKey) async {
    try {
      Uri uri = Uri.parse(ConstantApp.booksAPi);

      print('🌐 [API CALL] URL: $uri');

      final res = await http.get(
        uri,
        headers: {'x-api-key': apiKey},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        print('✅ [API] Successfully parsed response');
        return LibraryResponse.fromJson(data);
      } else {
        print('❌ [API] Error: ${res.statusCode}');
        throw Exception('API error: ${res.statusCode}');
      }
    } catch (e, s) {
      print('🔥 [EXCEPTION] fetchLibrary: $e');
      print('📜 [STACKTRACE] $s');
      rethrow;
    }
  }

  Future<List<BookModel>> fetchBooksByCategoriesId(int catId) async {
    try {
      final uri = Uri.parse(ConstantApp.booksAPi).replace(
        queryParameters: {
          'category_id': catId.toString(),
        },
      );
      final res = await http.get(
        uri,
        headers: {'x-api-key': ConstantApp.apiKey},
      );

      print('🟡 [DEBUG] Status Code: ${res.statusCode}');

      print('🟡 [DEBUG] Raw Response: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data['books'] == null) {
          print('⚠️ [WARNING] Response does not contain "books" key!');
          return [];
        }

        final books =
            (data['books'] as List).map((e) => BookModel.fromJson(e)).toList();

        books.sort((a, b) => a.idShow.compareTo(b.idShow));

        return books;
      } else {
        print('❌ [ERROR] API returned status ${res.statusCode}');
        throw Exception('خطا در دریافت لیست کتاب‌ها: ${res.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🔥 [EXCEPTION] Error in fetchBooks: $e');
      print('📜 [STACKTRACE]\n$stackTrace');
      throw Exception('خطا در پردازش یا اتصال به سرور: $e');
    }
  }

  String imageUrl(String imgPath) {
    return ConstantApp.upload + imgPath;
  }
}
