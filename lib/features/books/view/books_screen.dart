// books_screen.dart (clean version)

import 'package:bookapp/core/extensions/widget_ex.dart';
import 'package:bookapp/core/utils/cubit_progress_download_books/cubit/dow_progress_books_cubit.dart';
import 'package:bookapp/core/utils/progress_book_download.dart';
import 'package:bookapp/features/books/bloc/book/book_cubit.dart';
import 'package:bookapp/features/books/bloc/book/book_state.dart';
import 'package:bookapp/features/books/bloc/download/download_cubit.dart';
import 'package:bookapp/features/books/bloc/download/download_state.dart';
import 'package:bookapp/features/books/bloc/header_anim/cubit/header_animation_cubit.dart';
import 'package:bookapp/features/books/repositoreis/book_repository.dart';
import 'package:bookapp/features/books/widgets/book_item.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/gen/fonts.gen.dart';
import 'package:bookapp/core/utils/check_connection.dart'; // [New]
import 'package:bookapp/shared/ui_helper/dialog_common.dart';
import 'package:bookapp/shared/ui_helper/snackbar_common.dart';
import 'package:bookapp/shared/utils/error_widget.dart';
import 'package:bookapp/shared/utils/esay_size.dart';
import 'package:bookapp/shared/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HeaderAnimationCubit(),
        ),
        BlocProvider(
          create: (context) => BookCubit(context.read<BookRepository>())
            ..loadBooks(), // [Sync] Pass dependency
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container().animate().fadeIn(duration: 500.ms).scale(
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          title: Text(
            'تحميل الكتب',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontFamily: FontFamily.app),
          ),
          centerTitle: true,
          leadingWidth: 100,
          leading: const DownloadProgressBar(),
          actions: [
            _DownloadAllButton(),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<BookCubit, BookState>(
              listener: (context, state) {
                if (state is BookLoaded) {
                  context.read<DowProgressBooksCubit>().updateProgress();
                }
              },
            ),
            BlocListener<DownloadCubit, Map<String, DownloadState>>(
              listenWhen: (previous, current) {
                for (final key in current.keys) {
                  final prevItem = previous[key];
                  final currItem = current[key];
                  if (currItem?.isDownloadedBook == true &&
                      (prevItem?.isDownloadedBook != true)) {
                    return true;
                  }
                }
                return false;
              },
              listener: (context, state) {
                context.read<DowProgressBooksCubit>().updateProgress();
              },
            ),
          ],
          child: BlocBuilder<BookCubit, BookState>(
            builder: (context, state) {
              if (state is BookLoading) {
                return Center(child: CustomLoading.fadingCircle(context));
              } else if (state is BookError) {
                return Center(
                  child: ApiErrorWidget(
                    onRetry: () => context.read<BookCubit>().loadBooks(),
                  ),
                );
              } else if (state is BookLoaded) {
                final downloadCubit = context.read<DownloadCubit>();
                for (var book in state.books) {
                  downloadCubit.checkIfDownloaded(
                    book.id.toString(),
                  );
                  downloadCubit.checkIfBookDownloaded(book.id.toString());
                }
                return Column(
                  children: [
                    BlocBuilder<HeaderAnimationCubit, bool>(
                      builder: (context, animState) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child,
                            );
                          },
                          child: animState
                              ? Container(
                                  alignment: Alignment.center,
                                  key: ValueKey('bar'),
                                  width: EsaySize.width(context),
                                  height: EsaySize.height(context) / 10,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  child: TextField(
                                    controller: controller,
                                    onChanged: (value) {
                                      context.read<BookCubit>().search(value);
                                    },
                                    style: TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'ابحث عن كتاب...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Assets.newicons.search
                                          .image(
                                              width: 10,
                                              height: 10,
                                              color: Colors.grey)
                                          .padAll(14),
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color: Colors.black12, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1.4),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(
                                  key: ValueKey('empty'),
                                ),
                        );
                      },
                    ),
                    Expanded(child: BookDownloadList(books: state.books)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _DownloadAllButton extends StatelessWidget {
  const _DownloadAllButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ZoomTapAnimation(
        onTap: () async {
          if (!await hasInternetConnection()) {
            AppSnackBar.showError(context, 'لا يوجد اتصال بالإنترنت');
            return;
          }
          final state = context.read<BookCubit>().state;
          if (state is BookLoaded && state.books.isNotEmpty) {
            AppDialog.showConfirmDialog(
              context,
              title: 'تحميل جميع الكتب',
              content: 'هل أنت متأكد أنك تريد تحميل جميع الكتب؟',
              onPress: () async {
                context.read<DownloadCubit>().downloadAll(state.books);
              },
            );
          }
        },
        child: Assets.icons.downloadAll.image(
          width: 30,
          height: 30,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
