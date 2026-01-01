import 'package:bookapp/shared/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  double _progress = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: _progress < 1.0
              ? CustomLoading.fadingCircle(context)
              : const SizedBox.shrink(),
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
                        line-height: 1.6; 
                        color: #333;
                        direction: rtl; /* برای متون فارسی */
                      }
                      img { max-width: 100%; height: auto; border-radius: 12px; }
                      h1, h2, h3 { color: #1A237E; }
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
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
                if (_progress == 1.0) _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }
}
