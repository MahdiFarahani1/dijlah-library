import 'package:bookapp/core/utils/check_connection.dart';
import 'package:bookapp/features/mainWrapper/view/navigaion.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

Future<void> appEntryGuard(BuildContext context) async {
  final box = GetStorage();
  final firstLaunchDone = box.read('first_launch_completed') ?? false;

  if (!firstLaunchDone) {
    final online = await hasInternetConnection();

    if (!online) {
      await showForceInternetDialog(context);

      // وقتی دیالوگ بسته شد یعنی اینترنت وصل شده
      box.write('first_launch_completed', true);
    } else {
      box.write('first_launch_completed', true);
    }
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainWrapper()),
  );
}

Future<void> showForceInternetDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 Lottie Animation
                SizedBox(
                  height: 140,
                  child: Lottie.asset(
                    Assets.lottie.noConnection,
                    repeat: true,
                  ),
                ),

                const SizedBox(height: 16),

                // 🔴 Title
                Text(
                  'يتطلب اتصال بالإنترنت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),

                const SizedBox(height: 10),

                // 📝 Description
                const Text(
                  'للدخول إلى التطبيق لأول مرة، يجب أن يكون جهازك متصلاً بالإنترنت.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Color.fromARGB(255, 255, 159, 152)),
                ),

                const SizedBox(height: 24),

                // 🟢 Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final hasNet = await hasInternetConnection();
                      if (hasNet) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
