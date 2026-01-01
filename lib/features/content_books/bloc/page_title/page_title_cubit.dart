import 'package:bloc/bloc.dart';

abstract class PageTitleState {
  final String title;
  const PageTitleState(this.title);
}

class PageTitleDefault extends PageTitleState {
  const PageTitleDefault(super.title);
}

class PageTitleDragging extends PageTitleState {
  const PageTitleDragging(super.title);
}

class PageTitleCubit extends Cubit<PageTitleState> {
  final String bookName;
  PageTitleCubit(this.bookName) : super(PageTitleDefault(bookName));

  void showPageNumber(double page) {
    emit(PageTitleDragging('صفحة ${page.toInt()}'));
  }

  void resetTitle() {
    emit(PageTitleDefault(bookName));
  }
}
