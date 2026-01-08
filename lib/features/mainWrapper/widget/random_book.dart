import 'dart:typed_data';
import 'package:bookapp/features/content_books/view/content_page.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/utils/esay_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bookapp/features/books/model/book_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RandomBookCard extends StatefulWidget {
  final BookItem book;
  const RandomBookCard({required this.book, super.key});

  @override
  State<RandomBookCard> createState() => _RandomBookCardState();
}

class _RandomBookCardState extends State<RandomBookCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<SettingsCubit>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              fullscreenDialog: false,
              builder: (_) => ContentPage(
                bookId: widget.book.id,
                bookName: widget.book.title,
                scrollPosetion: 0,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.darkMode
                ? const Color.fromARGB(255, 27, 27, 27)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// اطلاعات سمت چپ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Assets.newicons.userWriter.image(
                            width: 20,
                            height: 20,
                            color: theme.textTheme.bodySmall!.color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoChip(
                      label: ' عدد الصفحات : ${widget.book.pageNumbers}',
                    ),
                    EsaySize.gap(8),
                    _CategoryChip(
                      category: widget.book.category,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(widget.book.imageData),
                  width: 90,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        )
            .animate(
              key: ValueKey(
                  widget.book.id), // ← هر بار book تغییر کرد، انیمیشن اجرا شود
            )
            .fade(duration: 400.ms)
            .slide(begin: const Offset(0.3, 0), duration: 400.ms),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Assets.newicons.page.image(
              width: 15,
              height: 15,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<SettingsCubit>().state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.darkMode
              ? [
                  theme.appBarTheme.backgroundColor!,
                  const Color.fromARGB(255, 63, 63, 63),
                ]
              : [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            Assets.newicons.categoryAlt.image(
              width: 15,
              height: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
