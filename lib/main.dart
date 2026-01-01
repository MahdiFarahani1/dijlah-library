import 'dart:io';

import 'package:bookapp/config/splash/splash.dart';
import 'package:bookapp/core/utils/check_connection.dart';
import 'package:bookapp/core/utils/cubit_progress_download_books/cubit/dow_progress_books_cubit.dart';
import 'package:bookapp/core/utils/connection/connection_cubit.dart'; // [New]
import 'package:bookapp/features/books/bloc/book/book_cubit.dart';
import 'package:bookapp/features/books/bloc/download/download_cubit.dart';
import 'package:bookapp/features/books/bloc/downloaded_page/downloaded_page_cubit.dart';
import 'package:bookapp/features/books/repositoreis/book_repository.dart';
import 'package:bookapp/features/content_books/bloc/bookmark/bookmark_cubit.dart';
import 'package:bookapp/features/mainWrapper/bloc/navbar/navigation_cubit.dart';
import 'package:bookapp/features/mainWrapper/bloc/slider/slider_cubit.dart';
import 'package:bookapp/features/onbording/onbording_view.dart';
import 'package:bookapp/features/reading_progress/bloc/cubit/readingbook_cubit.dart';
import 'package:bookapp/features/search/bloc/search_cubit.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/features/settings/bloc/settings_state.dart';
import 'package:bookapp/features/storage/bloc/page_bookmark/page_bookmark_cubit.dart';
import 'package:bookapp/firebase_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    if (await hasInternetConnection()) {
      await Firebase.initializeApp();

      await FirebaseNotificationService().initializeNotifications();

      FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
    } else {
      print("🚫 No internet — Firebase setup skipped");
    }
  }
  final dir = await getApplicationDocumentsDirectory();
  print('📁 App Documents Directory: ${dir.path}/books');
  print('-----------------------------');

  final entities = dir.listSync(recursive: true);

  for (final entity in entities) {
    if (entity is File) {
      print('📄 FILE: ${entity.path}');
    } else if (entity is Directory) {
      print('📂 DIR : ${entity.path}');
    }
  }

  print('-----------------------------');
  await GetStorage.init();

  // Initialize SQLite FFI on desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    databaseFactory = sqflite.databaseFactory;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DownloadCubit(),
        ),
        BlocProvider(
          create: (_) => DownloadedBooksCubit(),
        ),
        BlocProvider(
          create: (context) => ReadingbookCubit(),
        ),
        BlocProvider(
          create: (_) => SearchCubit(),
        ),
        BlocProvider(
          create: (context) => SliderCubit(),
        ),
        BlocProvider(
          create: (context) => BookmarkCubit(),
        ),
        BlocProvider(
          create: (_) => PageBookmarkCubit(GetStorage())..loadBookmarks(),
        ),
        BlocProvider(
          create: (context) => SettingsCubit(),
        ),
        BlocProvider(
          create: (context) => NavigationCubit(),
        ),
        BlocProvider(
          create: (context) => BookCubit(BookRepository()),
        ),
        RepositoryProvider<BookRepository>(
          create: (_) => BookRepository(),
        ),
        BlocProvider(
          create: (context) => DowProgressBooksCubit()..initialize(),
        ),
        BlocProvider(
          create: (_) => ConnectionCubit(), // [New]
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          GetStorage box = GetStorage();
          final onBordingShow = box.read('onbording') ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale('ar'),
            supportedLocales: const [
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: settingsState.theme,
            // darkTheme: AppTheme.darkTheme,
            home: onBordingShow ? SplashScreen() : const OnboardingPage(),
          );
        },
      ),
    );
  }
}
