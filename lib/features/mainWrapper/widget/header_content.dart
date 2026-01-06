import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shimmer/shimmer.dart';

Color getBaseColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF3A3A3A)
        : Colors.grey.shade300;

Color getHighlightColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF4A4A4A)
        : Colors.grey.shade100;

/// 🔹 رنگ متن WebView بر اساس تم
Color getTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;

/// 🔹 رنگ هدر‌ها (h1,h2,h3)
Color getHeaderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.tealAccent
        : Color(0xFF1A237E);

/// 🔹 رنگ بک‌گراند WebView
Color getWebViewBackgroundColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF1E1E1E)
        : Colors.white;

/// تبدیل رنگ Flutter به CSS hex
String colorToCssHex(Color color) {
  return '#${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}

class HeaderContentPage extends StatefulWidget {
  final String title;
  final String htmlContent;

  const HeaderContentPage({
    super.key,
    required this.title,
    required this.htmlContent,
  });

  @override
  State<HeaderContentPage> createState() => _HeaderContentPageState();
}

class _HeaderContentPageState extends State<HeaderContentPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final textColor = getTextColor(context);
    final headerColor = getHeaderColor(context);
    final bgColor = getWebViewBackgroundColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: """
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { 
                font-family: 'Tahoma', sans-serif; 
                padding: 20px; 
                line-height: 1.8; 
                color: ${colorToCssHex(textColor)};
                background-color: ${colorToCssHex(bgColor)};
                direction: rtl;
              }
              img { max-width: 100%; height: auto; border-radius: 12px; }
              h1, h2, h3 { color: ${colorToCssHex(headerColor)}; }
            </style>
          </head>
          <body>
            ${widget.htmlContent}
          </body>
        </html>
      """,
            ),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              supportZoom: false,
            ),
            onLoadStop: (controller, url) {
              if (_isLoading) {
                setState(() => _isLoading = false);
              }
            },
          )
              .animate(target: _isLoading ? 0 : 1)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0),

          /// 🔹 Shimmer Overlay
          if (_isLoading) const Positioned.fill(child: WebViewTextShimmer()),
        ],
      ),
    );
  }
}

class WebViewTextShimmer extends StatelessWidget {
  const WebViewTextShimmer({super.key});

  Widget _line(
    BuildContext context, {
    required double width,
    double height = 14,
    double radius = 6,
  }) {
    final baseColor = getBaseColor(context);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: getBaseColor(context),
        highlightColor: getHighlightColor(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(context, width: w * 0.5, height: 22),
            const SizedBox(height: 24),
            _line(context, width: w),
            const SizedBox(height: 10),
            _line(context, width: w),
            const SizedBox(height: 10),
            _line(context, width: w * 0.85),
            const SizedBox(height: 24),
            _line(context, width: w),
            const SizedBox(height: 10),
            _line(context, width: w),
            const SizedBox(height: 10),
            _line(context, width: w * 0.7),
            const SizedBox(height: 24),
            _line(context, width: w),
            const SizedBox(height: 10),
            _line(context, width: w * 0.9),
            const SizedBox(height: 10),
            _line(context, width: w * 0.6),
          ],
        ),
      ),
    );
  }
}
