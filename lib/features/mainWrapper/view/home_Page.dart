import 'dart:io';
import 'dart:typed_data';

// import removed: books_downloaded.dart (unused)
// import removed: books_screen.dart (unused)
import 'package:bookapp/features/books/bloc/downloaded_page/downloaded_page_cubit.dart';
import 'package:bookapp/features/books/bloc/downloaded_page/downloaded_page_state.dart';
import 'package:bookapp/features/books/model/book_item_model.dart';
import 'package:bookapp/features/content_books/view/content_page.dart';
import 'package:bookapp/features/mainWrapper/bloc/slider/slider_cubit.dart';
import 'package:bookapp/features/mainWrapper/view/all_readingbook.dart';
import 'package:bookapp/features/mainWrapper/view/componies_books_view.dart';
import 'package:bookapp/features/mainWrapper/widget/dialog_componies.dart';
// import removed: bookitem.dart (unused)
import 'package:bookapp/features/mainWrapper/widget/empty_reading.dart';
import 'package:bookapp/features/mainWrapper/widget/random_book.dart';
import 'package:bookapp/core/utils/shimmer_home.dart';
import 'package:bookapp/features/reading_progress/bloc/cubit/readingbook_cubit.dart';
import 'package:bookapp/features/search/view/search_screen.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/features/books/bloc/download/download_cubit.dart';
import 'package:bookapp/features/books/bloc/download/download_state.dart';
import 'package:bookapp/features/settings/bloc/settings_state.dart';
import 'package:bookapp/shared/func/launchURL.dart';
// imports removed: storage_comment_screen.dart, storage_page_screen.dart (unused)
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/ui_helper/snackbar_common.dart';
import 'package:bookapp/shared/utils/esay_size.dart';
// import removed: launchURL.dart (unused)
import 'package:bookapp/shared/utils/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
// import removed: share_plus (unused)
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:path/path.dart' as p;
import 'package:bookapp/shared/func/folder_check.dart';
import 'package:bookapp/core/utils/connection/connection_cubit.dart'; // [New]
import 'package:bookapp/features/mainWrapper/widget/sticky_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  List<String> animatedIconList = [
    Assets.images.sourceDocument.path,
    Assets.images.teamCheck.path,
    Assets.images.insurance.path,
    Assets.images.rules.path,
    Assets.images.follow.path,
  ];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    context.read<SliderCubit>().loadHomeData();

    context.read<ReadingbookCubit>().getReadingDataFromDb();
    context.read<DownloadedBooksCubit>().loadCategoryBooks();

    context
        .read<DownloadedBooksCubit>()
        .loadDownloadedBooks(context, categoryId: null);
    context.read<DownloadedBooksCubit>().initial(_scrollController);
    // Default to load ALL downloaded books on start (categoryId == null means ALL)
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent - 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<ConnectionCubit, ConnectionStat>(
        listenWhen: (previous, current) =>
            previous.status == ConnectionStatus.offline &&
            current.status == ConnectionStatus.online,
        listener: (context, state) {
          print('🌐 [Home] Connection restored. Refreshing data...');
          context.read<SliderCubit>().loadHomeData();
          // Reload downloaded books (will trigger sync)
          context
              .read<DownloadedBooksCubit>()
              .loadDownloadedBooks(context, categoryId: null);

          AppSnackBar.showSuccess(
            context,
            'تم استعادة الاتصال بالإنترنت',
          );
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<SliderCubit>().loadHomeData();

            await context.read<DownloadedBooksCubit>().loadCategoryBooks();

            await context
                .read<DownloadedBooksCubit>()
                .loadDownloadedBooks(context, categoryId: null);
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 0.0, vertical: 0.0), // No Listeners Here
                child: BlocBuilder<ReadingbookCubit, ReadingbookState>(
                  builder: (context, readingState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 Sticky Header
                        BlocBuilder<ConnectionCubit, ConnectionStat>(
                          builder: (context, state) {
                            if (state.status == ConnectionStatus.offline) {
                              return SizedBox.shrink();
                            }
                            return SizedBox(
                              height: 85,
                            );
                          },
                        ),
                        // 🔍 Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SearchPage()),
                              );
                            },
                            child: Container(
                              width: EsaySize.width(context) * 0.95,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                children: [
                                  Assets.newicons.search.image(
                                      width: 20,
                                      height: 20,
                                      color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Text(
                                    'ابحث عن كتاب أو مؤلف...',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.2, end: 0),
                        const SizedBox(height: 15.0),
                        // 🖼️ Image Slider
                        BlocBuilder<SliderCubit, SliderState>(
                          builder: (context, state) {
                            if (state.statusSlider is SliderLoading) {
                              return SizedBox(
                                height: 160,
                                child: Center(child: SliderShimmer()),
                              );
                            } else if (state.statusSlider is SliderLoaded) {
                              final sliders =
                                  (state.statusSlider as SliderLoaded).sliders;
                              return Column(
                                children: [
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    double sliderHeight = 110;
                                    double viewportFraction = 0.98;
                                    double borderRadius = 15;
                                    double indicatorSize = 6;
                                    double indicatorSpacing = 4;

                                    if (width >= 1200) {
                                      // دسکتاپ
                                      sliderHeight = 280;
                                      viewportFraction = 0.7;
                                      borderRadius = 20;
                                      indicatorSize = 10;
                                      indicatorSpacing = 6;
                                    } else if (width >= 800) {
                                      // تبلت
                                      sliderHeight = 220;
                                      viewportFraction = 0.8;
                                      borderRadius = 18;
                                      indicatorSize = 8;
                                      indicatorSpacing = 5;
                                    }

                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: EsaySize.width(context) * 0.95,
                                          height: sliderHeight,
                                          child: CarouselSlider(
                                            options: CarouselOptions(
                                              height: sliderHeight,
                                              autoPlay: true,
                                              enlargeCenterPage: true,
                                              viewportFraction:
                                                  viewportFraction,
                                              onPageChanged: (index, reason) {
                                                context
                                                    .read<SliderCubit>()
                                                    .indicatorChanged(index);
                                              },
                                            ),
                                            items: sliders.map((slider) {
                                              return GestureDetector(
                                                onTap: () {
                                                  if (slider.link == null ||
                                                      slider.link!.isEmpty) {
                                                    AppSnackBar.showInfo(
                                                        context,
                                                        ' لا يوجد رابط متاح');
                                                  } else {
                                                    LaunchUrl
                                                        .launchExternalLink(
                                                            slider.link);
                                                  }
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          borderRadius),
                                                  child: Image.network(
                                                    slider.photoUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                                )
                                                    .animate()
                                                    .fadeIn(duration: 800.ms)
                                                    .scale(
                                                        begin:
                                                            Offset(0.8, 0.8)),
                                              );
                                            }).toList(),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 700.ms,
                                                  delay: 200.ms)
                                              .slideX(begin: 0.3),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            sliders.length,
                                            (index) => AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: indicatorSpacing),
                                              width: state.currentIndex == index
                                                  ? indicatorSize
                                                  : indicatorSize - 2,
                                              height:
                                                  state.currentIndex == index
                                                      ? indicatorSize
                                                      : indicatorSize - 2,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    state.currentIndex == index
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              );
                            } else if (state.currentIndex is SliderError) {
                              return Text('!!!!!!!!!!');
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                        const SizedBox(height: 20.0),
                        BlocBuilder<ReadingbookCubit, ReadingbookState>(
                          builder: (context, state) {
                            if (state.status == ReadingbookStatus.loading) {
                              return const ReadingBooksShimmer();
                            }

                            if (state.status == ReadingbookStatus.error) {
                              return const Center(
                                child: Text('خطأ في تحميل الكتب'),
                              );
                            }

                            if (state.books.isEmpty) {
                              return const Center(
                                child: EmptyProgressBox(),
                              );
                            }
                            if (state.status == ReadingbookStatus.success) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: SectionHeader(
                                            title: 'اكمال المطالعة',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReadingBooksScreen(
                                                          readingBooks:
                                                              state.books,
                                                        )),
                                              );
                                            })
                                        .animate(delay: 800.ms)
                                        .fadeIn(duration: 700.ms)
                                        .slideX(begin: -0.3),
                                  ),
                                  const SizedBox(height: 15.0),
                                  SizedBox(
                                    height: 280,
                                    child: FutureBuilder<Directory>(
                                      future: getBooksBaseDir(),
                                      builder: (context, baseSnap) {
                                        if (!baseSnap.hasData) {
                                          return const SizedBox();
                                        }
                                        final baseDir = baseSnap.data!;
                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: state.books.length > 7
                                              ? 7
                                              : state.books.length,
                                          itemBuilder: (context, index) {
                                            final book = state.books[index];
                                            final double current =
                                                book['scrollposition'];
                                            final int total = book['pagesL'];

                                            final double percent =
                                                total > 0 ? current / total : 0;

                                            final String percentText =
                                                '${(percent * 100).toStringAsFixed(0)}%';

                                            final String bookId =
                                                book['book_id'].toString();
                                            final String imagePath = p.join(
                                                baseDir.path,
                                                'tmp',
                                                bookId,
                                                '$bookId.jpg');

                                            return ZoomTapAnimation(
                                              onTap: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ContentPage(
                                                            bookId: bookId,
                                                            bookName: book[
                                                                'book_name'],
                                                            scrollPosetion:
                                                                current,
                                                          )),
                                                );
                                              },
                                              child: Container(
                                                width: 145,
                                                margin: const EdgeInsets.only(
                                                    right: 15.0),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14.0),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    FutureBuilder<bool>(
                                                      future: File(imagePath)
                                                          .exists(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return SizedBox(
                                                            width: 100,
                                                            height: 140,
                                                            child: Center(
                                                                child: CustomLoading
                                                                    .fadingCircle(
                                                                        context)),
                                                          );
                                                        } else if (snapshot
                                                                .hasData &&
                                                            snapshot.data ==
                                                                true) {
                                                          return Container(
                                                            width: 150,
                                                            height: 180,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.1),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 4),
                                                                ),
                                                              ],
                                                            ),
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                            child: Image.file(
                                                              File(imagePath),
                                                              fit: BoxFit.cover,
                                                            )
                                                                .animate()
                                                                .fadeIn(
                                                                    duration:
                                                                        500.ms)
                                                                .scale(
                                                                    begin: const Offset(
                                                                        0.95,
                                                                        0.95))
                                                                .shimmer(
                                                                    duration:
                                                                        1000.ms,
                                                                    delay:
                                                                        300.ms),
                                                          );
                                                        } else {
                                                          return Container(
                                                            width: 100,
                                                            height: 140,
                                                            color: Colors
                                                                .grey.shade300,
                                                            child: const Center(
                                                                child: Icon(Icons
                                                                    .image_not_supported)),
                                                          )
                                                              .animate()
                                                              .fadeIn(
                                                                  duration:
                                                                      600.ms)
                                                              .scale(
                                                                  begin:
                                                                      const Offset(
                                                                          0.9,
                                                                          0.9))
                                                              .shimmer(
                                                                  duration:
                                                                      1200.ms,
                                                                  delay:
                                                                      400.ms);
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Text(
                                                      book['book_name'],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                        .animate()
                                                        .fadeIn(
                                                            duration: 500.ms,
                                                            delay: 300.ms)
                                                        .slideY(begin: 0.3),
                                                    const SizedBox(height: 4.0),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'الصفحة: ${current.toStringAsFixed(0)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        )
                                                            .animate()
                                                            .fadeIn(
                                                                duration:
                                                                    500.ms,
                                                                delay: 400.ms)
                                                            .slideY(begin: 0.3),
                                                        CircularPercentIndicator(
                                                          radius: 22.0,
                                                          lineWidth: 4.5,
                                                          percent: percent
                                                              .clamp(0.0, 1.0),
                                                          center: Text(
                                                            percentText,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          progressColor:
                                                              percent > 0.7
                                                                  ? Colors
                                                                      .greenAccent
                                                                      .shade400
                                                                  : Colors
                                                                      .amberAccent
                                                                      .shade400,
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade300,
                                                          animation: true,
                                                          animationDuration:
                                                              800,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }

                            return SizedBox();
                          },
                        ),
                        const SizedBox(height: 20.0),
                        // 📚 Downloaded Books Section
                        // (instant refresh on complete)

                        BlocSelector<DownloadedBooksCubit, DownloadedBooksState,
                            BookItem?>(
                          selector: (state) => state.randomBook,
                          builder: (context, book) {
                            if (book == null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                headerTile(context, 'الكتب المقروءة', 16),
                                RandomBookCard(book: book),
                              ],
                            );
                          },
                        ),

                        BlocSelector<SliderCubit, SliderState, StatusCompanies>(
                          selector: (state) => state.statusCompanies,
                          builder: (context, companies) {
                            if (companies is CompaniesLoading) {
                              return const CompaniesShimmerAnimated();
                            }

                            if (companies is CompaniesLoaded) {
                              final companiesData = (companies).companies;

                              return Column(
                                children: [
                                  headerTile(context, 'مواضيع مقترحة', 16),
                                  SizedBox(
                                    height: EsaySize.height(context) / 5.3,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: companiesData.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ComponiesBooksView(
                                                    apiKey: companiesData[index]
                                                        .apiToken!,
                                                  ),
                                                ));
                                          },
                                          child: Container(
                                            width: EsaySize.width(context) / 3,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: EsaySize.height(
                                                              context) /
                                                          12,
                                                      height: EsaySize.height(
                                                              context) /
                                                          12,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.15),
                                                      ),
                                                      child: Image.network(
                                                        companiesData[index]
                                                            .photoUrl!,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'عددُ الكُتُب : ${companiesData[index].booksCount}',
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                    const Divider(),
                                                    Expanded(
                                                      child: Text(
                                                        companiesData[index]
                                                            .title!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // 🔹 آیکن سه نقطه‌ای
                                                Positioned(
                                                  top: -6,
                                                  right:
                                                      -6, // اگه RTL هست و خواستی سمت چپ → left
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    onTap: () {
                                                      showCompanyDescriptionDialog(
                                                        context,
                                                        companiesData[index]
                                                                .description ??
                                                            '',
                                                        companiesData[index]
                                                                .title ??
                                                            '',
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface
                                                            .withOpacity(0.9),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.more_vert,
                                                        size: 20,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fade(duration: 1000.ms)
                                  .moveX(duration: 1000.ms);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 25.0),

                        BlocBuilder<DownloadedBooksCubit, DownloadedBooksState>(
                          builder: (context, state) {
                            if (state.categoryStatus
                                is DownloadedCategotyLoading) {
                              return const CategoriesShimmer();
                            }

                            if (state.categoryStatus
                                is DownloadedCategotyError) {
                              return const SizedBox(
                                height: 160,
                                child: Center(
                                    child: Text('خطأ في تحميل الكتب المنزلة')),
                              );
                            }

                            if (state.categoryStatus
                                is DownloadedCategotyLoaded) {
                              final categories = (state.categoryStatus
                                      as DownloadedCategotyLoaded)
                                  .categories;

                              final int totalCount = categories.fold<int>(
                                  0, (sum, c) => sum + c.booksCount);

                              final allCat = CategoryModel(
                                  id: -1,
                                  title: 'الكل',
                                  slug: '',
                                  booksCount: totalCount);

                              final displayCategories = [allCat, ...categories];

                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: displayCategories.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 4),
                                      itemBuilder: (context, index) {
                                        final isSelected =
                                            index == selectedIndex;
                                        final cat = displayCategories[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = index;
                                            });

                                            if (cat.id == -1) {
                                              // All
                                              context
                                                  .read<DownloadedBooksCubit>()
                                                  .loadDownloadedBooks(context,
                                                      categoryId: null);
                                            } else {
                                              context
                                                  .read<DownloadedBooksCubit>()
                                                  .loadDownloadedBooks(context,
                                                      categoryId: cat.id);
                                            }
                                          },
                                          child: BlocBuilder<SettingsCubit,
                                              SettingsState>(
                                            builder: (context, state) {
                                              final getColor = (state.darkMode
                                                  ? const Color.fromARGB(
                                                      255,
                                                      75,
                                                      75,
                                                      75) // Lighter for selected in dark mode
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .tertiary);
                                              return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? getColor
                                                      : (state.darkMode
                                                          ? const Color
                                                              .fromARGB(
                                                              255,
                                                              42,
                                                              42,
                                                              42) // Dark for unselected in dark mode
                                                          : Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: state.darkMode
                                                          ? Colors.transparent
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .tertiary),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      cat.title,
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : (state.darkMode
                                                                ? Colors.white
                                                                : Colors
                                                                    .black87),
                                                        fontWeight: isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                    EsaySize.gap(6),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color: !isSelected
                                                              ? (state.darkMode
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      60,
                                                                      60,
                                                                      60)
                                                                  : getColor)
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Text(
                                                        cat.booksCount
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: !isSelected
                                                              ? (state.darkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .white)
                                                              : (state.darkMode
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .black87),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ));
                            }

                            return const SizedBox();
                          },
                        ),

                        const SizedBox(height: 25.0),

                        BlocListener<DownloadCubit, Map<String, DownloadState>>(
                          // Only trigger when a book's downloaded flag flips to true
                          listenWhen: (previous, current) {
                            for (final entry in current.entries) {
                              final prev = previous[entry.key];
                              final curr = entry.value;
                              if ((prev == null ||
                                      prev.isDownloadedBook !=
                                          curr.isDownloadedBook) &&
                                  curr.isDownloadedBook) {
                                return true;
                              }
                            }
                            return false;
                          },
                          listener: (context, current) {
                            final downloadedCubit =
                                context.read<DownloadedBooksCubit>();
                            // determine reload category id
                            final catStatus =
                                downloadedCubit.state.categoryStatus;
                            int? reloadCategoryId;
                            if (selectedIndex == 0) {
                              reloadCategoryId = null;
                            } else if (catStatus is DownloadedCategotyLoaded) {
                              final categories = catStatus.categories;
                              final int catIndex = selectedIndex - 1;
                              if (catIndex >= 0 &&
                                  catIndex < categories.length) {
                                reloadCategoryId = categories[catIndex].id;
                              } else {
                                reloadCategoryId = null;
                              }
                            } else {
                              reloadCategoryId = null;
                            }

                            downloadedCubit.loadDownloadedBooks(context,
                                categoryId: reloadCategoryId);
                          },
                          child: BlocBuilder<DownloadedBooksCubit,
                              DownloadedBooksState>(
                            buildWhen: (previous, current) =>
                                previous.visableList != current.visableList ||
                                previous.booksStatus != current.booksStatus,
                            builder: (context, state) {
                              if (state.booksStatus is DownloadedBooksError) {
                                final String error =
                                    (state.booksStatus as DownloadedBooksError)
                                        .message;
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        error,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          context
                                              .read<DownloadedBooksCubit>()
                                              .loadDownloadedBooks(context);
                                        },
                                        child: const Text('إعادة المحاولة'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (state.booksStatus is DownloadedBooksLoading) {
                                return BooksGridShimmer(
                                  itemCount: 6,
                                  crossAxisCount:
                                      3, // می‌تونی با LayoutBuilder تنظیم کنی مثل Grid اصلی
                                  childAspectRatio: 0.62,
                                );
                              }

                              if (state.booksStatus is DownloadedBooksLoaded) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  print('object clicked ok ok kkk');
                                  _scrollToBottom();
                                });

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.visableList.isEmpty)
                                      SizedBox(
                                        height: 120,
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Assets.images.icons8Empty64.image(
                                                  color: Colors.grey.shade600),
                                              EsaySize.safeGap(10),
                                              Text(
                                                'لا توجد كتب مُنَزَّلة بعد',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ],
                                          ).animate().moveY(),
                                        ),
                                      )
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final width = constraints.maxWidth;
                                          int crossAxisCount =
                                              3; // mobile default: 3 per row
                                          double childAspectRatio = 0.62;
                                          if (width >= 1200) {
                                            crossAxisCount = 6;
                                            childAspectRatio = 0.72;
                                          } else if (width >= 900) {
                                            crossAxisCount = 5;
                                            childAspectRatio = 0.70;
                                          } else if (width >= 700) {
                                            crossAxisCount = 4;
                                            childAspectRatio = 0.68;
                                          } else if (width >= 500) {
                                            crossAxisCount = 3;
                                            childAspectRatio = 0.65;
                                          } else {
                                            crossAxisCount = 3;
                                            childAspectRatio = 0.62;
                                          }

                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                              childAspectRatio:
                                                  childAspectRatio,
                                            ),
                                            itemCount: state.visableList.length,
                                            itemBuilder: (context, index) {
                                              if (index ==
                                                  state.visableList.length) {}
                                              final vis =
                                                  state.visableList[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ContentPage(
                                                        bookId: vis.id,
                                                        bookName: vis.title,
                                                        scrollPosetion: 0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 10,
                                                        offset: Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: Image.memory(
                                                          Uint8List.fromList(
                                                              vis.imageData),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      // bottom gradient overlay
                                                      Positioned(
                                                        left: 0,
                                                        right: 0,
                                                        bottom: 0,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: BoxBorder.fromLTRB(
                                                                bottom: BorderSide(
                                                                    color: context
                                                                        .read<
                                                                            SettingsCubit>()
                                                                        .state
                                                                        .primry,
                                                                    width: 2)),
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.0),
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.55),
                                                              ],
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                vis.title,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              Text(
                                                                vis.author,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.85),
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // subtle top gradient
                                                      Positioned(
                                                        left: 0,
                                                        right: 0,
                                                        top: 0,
                                                        height: 40,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.25),
                                                                Colors
                                                                    .transparent,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    BlocSelector<DownloadedBooksCubit,
                                        DownloadedBooksState, bool>(
                                      selector: (state) => state.isLoading,
                                      builder: (context, isLoading) {
                                        if (!isLoading)
                                          return SizedBox.shrink();
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          width: double.infinity,
                                          height: 100,
                                          alignment: Alignment.center,
                                          child: CustomLoading.fadingCircle(
                                              context),
                                        );
                                      },
                                    ),
                                    EsaySize.gap(30),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<SliderCubit, SliderState>(
                builder: (context, state) {
                  if (state.statusPages is PagesLoading) {
                    return const FancyStickyHeaderShimmer();
                  }

                  if (state.statusPages is PagesLoaded) {
                    final pages = (state.statusPages as PagesLoaded).pages;
                    return FancyStickyHeader(
                      scrollController: _scrollController,
                      pageModel: pages,
                      icons: animatedIconList,
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget headerTile(BuildContext context, String title, double padH) {
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: 0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 3.5,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    ),
  );
}

class FeatureModel {
  final String icon;
  final String label;

  const FeatureModel({required this.icon, required this.label});
}

class FeatureItem extends StatelessWidget {
  final FeatureModel model;
  final VoidCallback onTap;

  const FeatureItem({
    super.key,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double iconSize = 34;
    double fontSize = 13;
    double spacing = 4;

    if (width >= 1200) {
      // دسکتاپ
      iconSize = 50;
      fontSize = 16;
      spacing = 12;
    } else if (width >= 800) {
      // تبلت
      iconSize = 40;
      fontSize = 14;
      spacing = 10;
    } else if (width >= 600) {
      spacing = 10;
    }

    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              model.icon,
              width: iconSize,
              height: iconSize,
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: Offset(0.5, 0.5))
                .shimmer(duration: 1000.ms),
            SizedBox(height: spacing),
            Text(
              model.label,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: fontSize),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  const SectionHeader(
      {super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerTile(context, title, 8),
        TextButton(
          onPressed: () {
            onPressed();
          },
          child: const Text(
            'عرض الكل',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: 0.3),
        ),
      ],
    );
  }
}
