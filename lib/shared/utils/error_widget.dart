import 'package:bookapp/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class ApiErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ApiErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // انیمیشن Lottie
                      Lottie.asset(
                        Assets.lottie.noConnection,
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 16),

                      // عنوان خطا
                      Text(
                        'حدث خطأ!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 8),

                      // توضیح خطا
                      Text(
                        'فشل الاتصال بالخادم. حاول مرة أخرى من فضلك.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 20),

                      // دکمه Retry
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: ElevatedButton.icon(
                          key: UniqueKey(), // جلوگیری از Key تکراری
                          onPressed: onRetry,
                          icon: Assets.newicons.messageCircleRefresh.image(
                            width: 20,
                            height: 20,
                            color: theme.colorScheme.surface,
                          ),
                          label: Text(
                            'حاول مرة أخرى',
                            style: TextStyle(
                              color: theme.colorScheme.surface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.surface,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
