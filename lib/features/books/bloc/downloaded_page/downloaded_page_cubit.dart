import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:bookapp/config/storage/download_progress_storage.dart';
import 'package:bookapp/core/utils/cubit_progress_download_books/cubit/dow_progress_books_cubit.dart';
import 'package:bookapp/features/books/bloc/downloaded_page/downloaded_page_state.dart';
import 'package:bookapp/features/books/model/book_item_model.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/shared/func/folder_check.dart';
import 'package:bookapp/features/books/repositoreis/book_list_db_helper.dart'; // [NEW] Import
import 'package:bookapp/features/books/repositoreis/book_repository.dart';
import 'package:bookapp/core/utils/sync_manager.dart'; // [New]
import 'package:bookapp/features/books/bloc/download/download_cubit.dart'; // [New] for Sync
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:math';

class DownloadedBooksCubit extends Cubit<DownloadedBooksState> {
  DownloadedBooksCubit() : super(DownloadedBooksState.initial());

  /// 🗂️ بارگذاری کتگوری‌ها از API
  /// 🗂️ بارگذاری کتگوری‌ها از API یا دیتابیس
  Future<void> loadCategoryBooks() async {
    try {
      emit(state.copyWith(categoryStatus: DownloadedCategotyLoading()));

      List<CategoryModel> allCategories;
      try {
        // تلاش برای دریافت از سرور
        allCategories = await BookRepository().fetchCategory();
        // ذخیره در دیتابیس
        await BookListDbHelper.insertCategories(allCategories);
      } catch (e) {
        print('⚠️ [Cubit] API failed ($e), loading categories from DB...');
        // در صورت خطا، دریافت از دیتابیس
        allCategories = await BookListDbHelper.getCategories();
      }

      if (allCategories.isEmpty) {
        emit(state.copyWith(
          categoryStatus: DownloadedCategotyError(
              "برای بار اول دریافت لیست نیاز به اینترنت دارید"),
        ));
      } else {
        emit(state.copyWith(
          categoryStatus: DownloadedCategotyLoaded(allCategories),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        categoryStatus: DownloadedCategotyError(e.toString()),
      ));
    }
  }

  Future<void> loadDownloadedBooks(
    BuildContext context, {
    int? categoryId,
  }) async {
    try {
      print(
          '🟢 [Cubit] Starting loadDownloadedBooks for category: ${categoryId ?? 'ALL'}');
      emit(state.copyWith(booksStatus: DownloadedBooksLoading()));

      // مرحله ۱: تلاش برای دریافت لیست کتاب‌ها از سرور و سینک با دیتابیس
      List<BookModel> availableBooksHelper;
      try {
        if (categoryId == null) {
          // [Sync] Incremental Sync Logic
          final localUpdate = await BookListDbHelper.getLastUpdate();
          print('🔄 [Sync] Local last_update: "$localUpdate"');

          final response =
              await BookRepository().fetchLibrary(lastUpdate: localUpdate);

          if (response != null) {
            DownloadProgressStorage.setTotalBooks(response.books.length);

            if (response.lastUpdate != localUpdate &&
                response.lastUpdate.isNotEmpty) {
              print(
                  '📥 [Sync] New update found (${response.lastUpdate}). Processing updates...');

              // [Sync] Use SyncManager for strict logic

              await SyncManager.syncBooks(
                  response.books, context.read<DownloadCubit>(), () {
                context
                    .read<DownloadedBooksCubit>()
                    .loadDownloadedBooks(context);
              }, isIncremental: localUpdate.isNotEmpty);

              await BookListDbHelper.setLastUpdate(response.lastUpdate);
            } else {
              print('✅ [Sync] No new updates.');
            }
          }
        } else {
          // For specific category, just fetch and insert (legacy/simple mode)
          availableBooksHelper =
              await BookRepository().fetchBooksByCategoriesId(categoryId);
          await BookListDbHelper.insertBooks(availableBooksHelper);
        }

        // [Fix] Set Total Books count from DB instead of API response to be accurate
        // We can get the count from the book list we are about to load later, or strict count query
        // For now, let's assume getBooks(null) gives us all? Or just skip setting it here?
        // The previous code set it from valid API response.
        // Let's set it after loading from DB.
      } catch (e) {
        print('⚠️ [Cubit] Sync/API failed ($e), falling back to DB...');
      }

      // مرحله ۲: خواندن از دیتابیس (چه سرور موفق بوده باشد چه نه، دیتابیس منبع حقیقت است)
      final List<BookModel> categoryBooks =
          await BookListDbHelper.getBooks(categoryId: categoryId);

      if (categoryBooks.isEmpty) {
        // چک کنیم اصلا دیتایی داریم؟
        final hasAnyData = await BookListDbHelper.hasData();
        if (!hasAnyData) {
          emit(state.copyWith(
            booksStatus: const DownloadedBooksLoaded([]),
            visableList: const [],
            randomBook: null,
          ));
          return;
        }
      }

      print(
          '📚 [Cubit] Using ${categoryBooks.length} books from local DB/Cache for processing zips');

      final baseDir = await getBooksBaseDir();
      print('📁 [Path] Books directory: ${baseDir.path}');

      if (!await baseDir.exists()) {
        print('⚠️ [Cubit] Directory not found → Emit empty list');
        emit(state.copyWith(booksStatus: const DownloadedBooksLoaded([])));
        return;
      }

      // مرحله ۴: پیدا کردن فایل‌های ZIP
      final zipFiles = baseDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.zip'))
          .toList();

      print('🧩 [Cubit] Found ${zipFiles.length} zip files.');

      final List<BookItem> localBooks = [];
      print('lenght zip files: ${zipFiles.length}');

      context.read<DowProgressBooksCubit>().updateProgress();
      // مرحله ۵: حلقه روی فایل‌ها
      for (final zipFile in zipFiles) {
        // print('\n🔹 [Loop] Checking ZIP: ${zipFile.path}');
        try {
          // بهینه سازی: اول اسم فایل رو چک کنیم ببینیم تو لیست ما هست یا نه؟
          // اگر لیست ما (categoryBooks) خالی باشه (افلاین بدون کش)، اینجا چیزی مچ نمیشه.

          // گرفتن آیدی کتاب از اسم فایل
          final idMatch =
              RegExp(r'book_(\d+)_db\.zip').firstMatch(zipFile.path);
          final id = idMatch?.group(1);
          if (id == null) {
            continue;
          }

          // آیا این کتاب در لیست فعلی (کتگوری انتخاب شده) وجود دارد؟
          // اگر categoryBooks خالی باشه (اینترنت نیست و دیتابیس هم خالیه) اینجا پیداش نمیکنه.
          // ولی ما بالا گفتیم اگه دیتابیس خالیه ارور بده.

          // جستجو در لیست کتاب‌های لود شده (categoryBooks)
          // استفاده از firstWhere با orElse برای جلوگیری از اکسپشن
          final existsInList = categoryBooks.any((b) => b.id.toString() == id);

          if (!existsInList) {
            // اگر در لیست این کتگوری نیست، پس نباید نمایش داده بشه (فیلتر کتگوری)
            // مگر اینکه categoryId == null باشه که باید باشه.
            continue;
          }

          final bookInfo = categoryBooks.firstWhere(
            (b) => b.id.toString() == id,
          );

          final bytes = await zipFile.readAsBytes();
          final archive = ZipDecoder().decodeBytes(bytes);

          // مرحله ۶: پیدا کردن تصویر داخل آرشیو
          final imageFile = archive.files.firstWhere(
            (f) =>
                f.isFile &&
                f.name.toLowerCase().contains(id) &&
                (f.name.toLowerCase().endsWith('.jpg') ||
                    f.name.toLowerCase().endsWith('.jpeg') ||
                    f.name.toLowerCase().endsWith('.png')),
            orElse: () => ArchiveFile('notfound', 0, Uint8List(0)),
          );

          if (imageFile.name == 'notfound' || imageFile.content.isEmpty) {
            // print('⚠️ [Image] Not found for book $id');
            continue;
          }

          // مرحله ۷: افزودن به لیست نهایی
          final imageBytes = imageFile.content as List<int>;
          localBooks.add(BookItem(
            category: bookInfo.category.title,
            pageNumbers: bookInfo.numberPages,
            id: id,
            imageData: imageBytes,
            title: bookInfo.title,
            author: bookInfo.writerName ??
                '', // استفاده از writerName چون در DB Helper مپ کردیم
            date: bookInfo.dateTime.toString() ?? '',
          ));

          // print('✅ [Add] Book added: ${bookInfo.title}');
        } catch (e) {
          // print('❌ [LoopError] $e');
          continue;
        }
      }
      final random = Random();
      final randomBook = localBooks.isNotEmpty
          ? localBooks[random.nextInt(localBooks.length)]
          : null;

      final reversedBooks = localBooks.reversed.toList();

      emit(state.copyWith(randomBook: randomBook));

      print(
          '\n📊 [Result] ${reversedBooks.length} valid books found for category $categoryId');

      List<BookItem> visableListNew =
          reversedBooks.take(state.itemPerCount).toList();

      // مرحله ۸: Emit نهایی
      emit(state.copyWith(
          booksStatus: DownloadedBooksLoaded(reversedBooks),
          visableList: visableListNew));
    } catch (e, s) {
      print('🔥 [GlobalError] $e\n$s');
      emit(state.copyWith(
        booksStatus: DownloadedBooksError(e.toString()),
      ));
    }
  }

  initial(ScrollController scrollController) {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !state.isLoading) {
        loadMoreItems();
      }
    });
  }

  Future<void> loadMoreItems() async {
    if (state.isLoading) return;
    if (state.booksStatus is! DownloadedBooksLoaded) return;

    final allBooks = (state.booksStatus as DownloadedBooksLoaded).books;

    if (state.visableList.length >= allBooks.length) return;

    emit(state.copyWith(isLoading: true));

    await Future.delayed(Duration(seconds: 1)); // اگه خواستی حذف کن

    final current = state.visableList.length;
    final next = current + state.itemPerCount;

    final newItems = allBooks.sublist(
      current,
      next > allBooks.length ? allBooks.length : next,
    );

    emit(state.copyWith(
      visableList: [...state.visableList, ...newItems],
      isLoading: false,
    ));
  }
}
