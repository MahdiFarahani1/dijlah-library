import 'package:bookapp/features/mainWrapper/model/slider_model.dart';
import 'package:bookapp/features/mainWrapper/widget/header_content.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FancyStickyHeader extends StatefulWidget {
  final ScrollController scrollController;
  final List<PageModel> pageModel;
  final List<String> icons;

  const FancyStickyHeader({
    super.key,
    required this.scrollController,
    required this.pageModel,
    required this.icons,
  });

  @override
  State<FancyStickyHeader> createState() => _FancyStickyHeaderState();
}

class _FancyStickyHeaderState extends State<FancyStickyHeader>
    with TickerProviderStateMixin {
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (!mounted) return;

      if (widget.scrollController.offset > 50 && !_collapsed) {
        setState(() => _collapsed = true);
      } else if (widget.scrollController.offset <= 50 && _collapsed) {
        setState(() => _collapsed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<SettingsCubit>().state;
    return Container(
      color:
          state.darkMode ? const Color.fromARGB(255, 27, 27, 27) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.pageModel.length, (index) {
          return Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeaderContentPage(
                        title: widget.pageModel[index].title,
                        htmlContent: widget.pageModel[index].content,
                      ),
                    ));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Icon با انیمیشن
                    AnimatedOpacity(
                      opacity: _collapsed ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _collapsed
                            ? SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Image.asset(widget.icons[index],
                                    width: 30,
                                    height: 30,
                                    color: Theme.of(context).primaryColor),
                              ),
                      ),
                    ),
                    !_collapsed ? const SizedBox(height: 4) : SizedBox.shrink(),
                    // 🔹 Text با انیمیشن و سه نقطه
                    AnimatedDefaultTextStyle(
                      style: TextStyle(
                          fontFamily: FontFamily.app,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        widget.pageModel[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
