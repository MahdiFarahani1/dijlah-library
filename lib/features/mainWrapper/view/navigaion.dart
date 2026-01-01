import 'package:bookapp/features/books/view/books_screen.dart';
import 'package:bookapp/features/mainWrapper/repository/first_enter_bool.dart';
import 'package:bookapp/features/mainWrapper/view/home_Page.dart';
import 'package:bookapp/features/mainWrapper/bloc/navbar/navigation_cubit.dart';
import 'package:bookapp/features/settings/bloc/settings_cubit.dart';
import 'package:bookapp/features/settings/bloc/settings_state.dart';
import 'package:bookapp/features/storage/view/storage_book_screen.dart';
import 'package:bookapp/features/storage/view/storage_page_screen.dart';
import 'package:bookapp/features/storage/view/storage_comment_screen.dart';
import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/scaffold/appbar.dart';
import 'package:bookapp/shared/scaffold/draver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainWrapper extends StatelessWidget {
  static final controllerNavBar = PersistentTabController(
      initialIndex: EnterStorageService().readFirstEnter() == true ? 0 : 1);
  const MainWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: CustomDrawer(),
      appBar: CustomAppbar.show(context),
      body: BlocBuilder<NavigationCubit, int>(
        builder: (context, state) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return PersistentTabView(
                controller: controllerNavBar,
                onTabChanged: (value) async {
                  BlocProvider.of<NavigationCubit>(context).setPage(value);
                  final isEnter = EnterStorageService().readFirstEnter();

                  if (!isEnter) {
                    EnterStorageService().saveFirstEnter(true);
                  }
                },
                tabs: [
                  // 1) المكتبة
                  navItem(
                      context: context,
                      settingsState: settingsState,
                      widthIcon: 20,
                      heightIcon: 20,
                      itemColor: state == 0
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      iconPath: Assets.newicons.bookOpenCover.path,
                      title: 'المكتبة',
                      screen: HomePage()),
                  // 2) تحميل
                  navItem(
                      context: context,
                      settingsState: settingsState,
                      widthIcon: 20,
                      heightIcon: 20,
                      itemColor: state == 1
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      iconPath: Assets.icons.upAndDownArrows.path,
                      title: 'تحميل',
                      screen: BooksScreen()),
                  // 3) المفضلة (الكتب المحفوظة)
                  navItem(
                      context: context,
                      settingsState: settingsState,
                      widthIcon: 20,
                      heightIcon: 20,
                      itemColor: state == 2
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      iconPath: Assets.newicons.bookmark.path,
                      title: 'المفضلة',
                      screen: const StorageBookScreen(
                        isBack: false,
                      )),
                  // 4) الاشارات (الصفحات المحفوظة)
                  navItem(
                      context: context,
                      settingsState: settingsState,
                      widthIcon: 20,
                      heightIcon: 20,
                      itemColor: state == 3
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      iconPath: Assets.newicons.circleBookmark.path,
                      title: 'الاشارات',
                      screen: const StoragePageScreen(
                        isBack: false,
                      )),
                  // 5) التعليقات
                  navItem(
                      context: context,
                      settingsState: settingsState,
                      widthIcon: 20,
                      heightIcon: 20,
                      itemColor: state == 4
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      iconPath: Assets.newicons.commentAltDots.path,
                      title: 'التعليقات',
                      screen: const CommentScreen(
                        isBack: false,
                      )),
                ],
                navBarBuilder: (navBarConfig) =>
                    BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return Style6BottomNavBar(
                        height: 65,
                        navBarConfig: navBarConfig,
                        navBarDecoration: NavBarDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          padding: EdgeInsets.all(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        itemAnimationProperties: ItemAnimation(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  PersistentTabConfig navItem(
      {required String iconPath,
      required String title,
      required Widget screen,
      required Color itemColor,
      required SettingsState settingsState,
      required BuildContext context,
      double? widthIcon,
      double? heightIcon}) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Image.asset(
              iconPath,
              width: widthIcon ?? 16,
              height: heightIcon ?? 16,
              color: itemColor,
            ),
          ),
          iconSize: 22,
          title: title,
          inactiveForegroundColor:
              Theme.of(context).primaryColor.withOpacity(0.3),
          activeForegroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(fontSize: 11)),
    );
  }
}
