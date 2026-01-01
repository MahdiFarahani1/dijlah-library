import 'package:url_launcher/url_launcher.dart';

class LaunchUrl {
  static const String email = 'almaerifa1234@gmail.com';
  static const String youtube = 'mailto:your_email@example.com';
  static const String instagram = 'mailto:your_email@example.com';
  static const String facebook = 'mailto:your_email@example.com';
  static const String twitter = 'mailto:your_email@example.com';

  static Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'التواصل معنا', 'body': 'مرحباً،'},
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication, // ⚠️ حیاتی
      );

      if (!launched) {
        throw 'Launch returned false';
      }
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  static Future<void> launchExternalLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
