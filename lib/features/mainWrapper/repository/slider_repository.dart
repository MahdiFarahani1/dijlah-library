import 'dart:convert';
import 'package:bookapp/core/constant/const_class.dart';
import 'package:bookapp/features/mainWrapper/model/slider_model.dart';
import 'package:http/http.dart' as http;

class SliderRepository {
  static const String apiUrl = "https://library.dijlah.org/api/v1/home";

  static Future<List<SliderModel>> fetchSliders() async {
    final response = await http
        .get(Uri.parse(apiUrl), headers: {'x-api-key': ConstantApp.apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List slidersJson = data['sliders'];

      return slidersJson.map((json) => SliderModel.fromJson(json)).toList();
    } else {
      throw Exception("خطا در دریافت اسلایدر");
    }
  }

  static Future<List<LastBookModel>> fetchLastBooks() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List slidersJson = data['last_books'];

      return slidersJson.map((json) => LastBookModel.fromJson(json)).toList();
    } else {
      throw Exception("خطا در دریافت اسلایدر");
    }
  }

  static Future<List<PageModel>> fetchPages() async {
    final response = await http
        .get(Uri.parse(apiUrl), headers: {'x-api-key': ConstantApp.apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List slidersJson = data['pages'];

      return slidersJson.map((json) => PageModel.fromJson(json)).toList();
    } else {
      throw Exception("خطا در دریافت pagessssssss");
    }
  }

  static Future<List<Company>> fetchCompanies() async {
    final response = await http
        .get(Uri.parse(apiUrl), headers: {'x-api-key': ConstantApp.apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List companiesJson = data['companies'];

      return companiesJson.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception("خطا در دریافت companiesssssss");
    }
  }
}
