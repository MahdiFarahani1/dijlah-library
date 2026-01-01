import 'package:bookapp/core/constant/const_class.dart';
import 'package:bookapp/core/utils/check_connection.dart'; // [New]
import 'package:bookapp/features/books/bloc/download/download_cubit.dart';
import 'package:bookapp/features/books/bloc/download/download_state.dart';
import 'package:bookapp/features/books/bloc/header_anim/cubit/header_animation_cubit.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/features/books/repositoreis/book_list_db_helper.dart';
import 'package:bookapp/features/books/repositoreis/book_repository.dart';
import 'package:bookapp/features/content_books/repository/dataBase.dart';
import 'package:bookapp/features/content_books/view/content_page.dart';
import 'package:bookapp/features/storage/repository/db_helper.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/func/downloaded_book.dart';
import 'package:bookapp/shared/ui_helper/snackbar_common.dart';
import 'package:bookapp/shared/utils/images_network.dart';
import 'package:bookapp/shared/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookItemTile extends StatelessWidget {
  final BookModel book;
  final BookRepository repo;

  const BookItemTile({
    required this.book,
    required this.repo,
    super.key,
  });

  // Helper for offline check
  Future<bool> _checkInternet(BuildContext context) async {
    if (!await hasInternetConnection()) {
      AppSnackBar.showError(context, 'لا يوجد اتصال بالإنترنت');

      return false;
    }
    return true;
  }

  // Future<bool> _requestStoragePermission() async {
  //   final status = await Permission.storage.status;
  //   if (status.isGranted) return true;

  //   final result = await Permission.storage.request();
  //   return result.isGranted;
  // }

  @override
  Widget build(BuildContext context) {
    print(book.photoUrl);
    final imageUrl = book.photoUrl;

    return BlocBuilder<DownloadCubit, Map<String, DownloadState>>(
      builder: (context, downloadStates) {
        final downloadState =
            downloadStates[book.id.toString()] ?? DownloadState();

        return GestureDetector(
          onTap: () {
            BookDatabaseHelper().inspectBookZip(15.toString());
            if (downloadState.isDownloadedBook) {
              print(
                book.id.toString(),
              );
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => ContentPage(
                    bookId: book.id.toString(),
                    bookName: book.title,
                    scrollPosetion: 0),
              ));
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImageNetworkCommon(
                    imageurl: imageUrl,
                    width: 75,
                    height: 105,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.writerName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'التاریخ: ${DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(book.dateTime * 1000))}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (book.pdfLink != null && book.pdfLink!.isNotEmpty)
                              ? Assets.newicons.filePdf.image(
                                  width: 22,
                                  height: 22,
                                  color: Theme.of(context).primaryColor)
                              : SizedBox.shrink(),
                          const SizedBox(width: 6),
                          (book.pdfLink != null && book.pdfLink!.isNotEmpty)
                              ? GestureDetector(
                                  onTap: downloadState.isDownloadingPdf
                                      ? null
                                      : () async {
                                          print(
                                              'pdf link book!!!!! ${book.pdfLink}');
                                          if (!await _checkInternet(context))
                                            return;

                                          handleDownloadOrOpen(
                                              context,
                                              downloadState,
                                              book.pdfLink,
                                              '${book.id}.pdf', () {
                                            context
                                                .read<DownloadCubit>()
                                                .startPdfDownload(
                                                    book.id.toString(),
                                                    book.pdfLink);
                                          });
                                        },
                                  child: Text(
                                    downloadState.isDownloadingPdf
                                        ? 'جاري التحميل..'
                                        : downloadState.isDownloadedPdf
                                            ? 'تصفح ملف PDF'
                                            : 'تحميل pdf',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: downloadState.isDownloadingPdf
                                          ? Colors.grey
                                          : const Color(0xFF2196F3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          const Spacer(),
                          ZoomTapAnimation(
                            onTap: () async {
                              if (downloadState.isDownloadedBook == false) {
                                if (!await _checkInternet(context))
                                  return; // [Check]

                                handleBookDownload(
                                  context,
                                  downloadState,
                                  ConstantApp.downloadBook + book.id.toString(),
                                  'book_${book.id.toString()}_db.zip',
                                  () async {
                                    await context
                                        .read<DownloadCubit>()
                                        .startBookDownload(
                                          book.id.toString(),
                                          '${ConstantApp.downloadBook}${book.id}',
                                        );
                                    DatabaseStorageHelper.insertBookNames(
                                        book.title, book.id);

                                    BookListDbHelper.upsertBook(book);
                                  },
                                );
                              }
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: downloadState.isDownloadedBook
                                    ? Colors.transparent
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(8),
                              child: downloadState.isDownloadingBook
                                  ? CustomLoading.fadingCircle(context)
                                  : downloadState.isDownloadedBook
                                      ? Assets.newicons.mapMarkerCheck
                                          .image(color: Colors.green)
                                          .animate()
                                          .scale(
                                              duration:
                                                  Duration(milliseconds: 400))
                                      : Assets.newicons.inboxIn.image(
                                          color:
                                              Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                      if (downloadState.isDownloadingPdf)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: downloadState.progressPdf,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookDownloadList extends StatefulWidget {
  final List<BookModel> books;
  const BookDownloadList({super.key, required this.books});

  @override
  State<BookDownloadList> createState() => _BookDownloadListState();
}

class _BookDownloadListState extends State<BookDownloadList> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    scrollController.addListener(() {
      final offset = scrollController.offset;

      if (offset > 0) {
        context.read<HeaderAnimationCubit>().hideHeader();
      } else {
        context.read<HeaderAnimationCubit>().showHeader();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<BookRepository>();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final book = widget.books.reversed.toList()[index];
        return BookItemTile(
          key: ValueKey(book.id),
          book: book,
          repo: repo,
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
