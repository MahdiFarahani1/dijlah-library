import 'dart:convert';
import 'package:bookapp/core/constant/const_class.dart';
import 'package:http/http.dart' as http;

class SliderRepository {
  static const String apiUrl = "https://library.dijlah.org/api/v1/home";

  /// فقط JSON خام برمیگردونه
  static Future<Map<String, dynamic>> fetchHomeJson() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'x-api-key': ConstantApp.apiKey},
    );

    if (response.statusCode != 200) {
      throw Exception("خطا در دریافت اطلاعات خانه");
    }

    return jsonDecode(response.body);
  }
}
