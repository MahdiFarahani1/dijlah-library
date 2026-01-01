import 'dart:io';
import 'package:bookapp/core/constant/const_class.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(double progress);
typedef CompleteCallback = void Function(String filePath);
typedef ErrorCallback = void Function(String error);

class FileDownloader {
  static Future<void> downloadFile({
    required String url,
    String? fileName,
    String? customDirectoryPath,
    String? customFullPath,
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
    ErrorCallback? onError,
  }) async {
    try {
      // مسیر ذخیره فایل
      Directory baseDir = await getApplicationDocumentsDirectory();
      String dirPath = customDirectoryPath ?? baseDir.path;

      String fullPath =
          '$dirPath/book_${fileName ?? url.split('/').last}_db.zip';

      String providedFullPath = customFullPath ?? fullPath;
      // ساخت دایرکتوری در صورت نیاز
      await Directory(dirPath).create(recursive: true);

      Dio dio = Dio();

      // تنظیمات هدر در صورت داشتن API KEY
      final options = Options(
        headers: {
          'x-api-key': ConstantApp.apiKey,
        },
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      );

      await dio.download(
        url,
        providedFullPath,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      print('✅ File saved at: $providedFullPath');
      onComplete?.call(providedFullPath);
    } catch (e) {
      print('❌ Download error: $e');
      onError?.call(e.toString());
    }
  }
}
