import 'dart:async';

import 'package:bookapp/config/splash/check_frist_time.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/utils/esay_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsCubit>().loadSettings();
    });

    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      await appEntryGuard(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 🔥 خیلی مهم
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: EsaySize.width(context),
        height: EsaySize.height(context),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.splash.path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
