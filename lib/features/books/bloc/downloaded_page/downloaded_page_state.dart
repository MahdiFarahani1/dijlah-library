import 'package:bookapp/features/books/model/book_item_model.dart';
import 'package:bookapp/features/books/model/model_books.dart';

class DownloadedBooksState {
  final DownloadedBooksStatus booksStatus;
  final DownloadedCategotyStatus categoryStatus;
  BookItem? randomBook;
  int itemPerCount;
  List<BookItem> visableList;
  bool isLoading;
  DownloadedBooksState({
    required this.booksStatus,
    required this.categoryStatus,
    this.itemPerCount = 9,
    this.visableList = const [],
    this.isLoading = false,
    this.randomBook,
  });

  factory DownloadedBooksState.initial() => DownloadedBooksState(
        booksStatus: DownloadedBooksLoading(),
        categoryStatus: DownloadedCategotyLoading(),
      );

  DownloadedBooksState copyWith({
    DownloadedBooksStatus? booksStatus,
    DownloadedCategotyStatus? categoryStatus,
    int? itemPerCount,
    List<BookItem>? visableList,
    bool? isLoading,
    BookItem? randomBook,
  }) {
    return DownloadedBooksState(
        booksStatus: booksStatus ?? this.booksStatus,
        categoryStatus: categoryStatus ?? this.categoryStatus,
        itemPerCount: itemPerCount ?? this.itemPerCount,
        visableList: visableList ?? this.visableList,
        isLoading: isLoading ?? this.isLoading,
        randomBook: randomBook ?? this.randomBook);
  }
}

abstract class DownloadedBooksStatus {
  const DownloadedBooksStatus();
}

class DownloadedBooksLoading extends DownloadedBooksStatus {}

class DownloadedBooksLoaded extends DownloadedBooksStatus {
  final List<BookItem> books;

  const DownloadedBooksLoaded(this.books);
}

class DownloadedBooksError extends DownloadedBooksStatus {
  final String message;

  const DownloadedBooksError(this.message);
}

//
// 🗂️ Category Status
//
abstract class DownloadedCategotyStatus {
  const DownloadedCategotyStatus();
}

class DownloadedCategotyLoading extends DownloadedCategotyStatus {}

class DownloadedCategotyLoaded extends DownloadedCategotyStatus {
  final List<CategoryModel> categories;

  const DownloadedCategotyLoaded(this.categories);
}

class DownloadedCategotyError extends DownloadedCategotyStatus {
  final String message;

  const DownloadedCategotyError(this.message);
}
