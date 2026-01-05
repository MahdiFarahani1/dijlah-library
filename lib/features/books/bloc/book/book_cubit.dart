import 'package:bloc/bloc.dart';
import 'package:bookapp/features/books/model/model_books.dart';
import 'package:bookapp/features/books/repositoreis/book_repository.dart';

import 'book_state.dart';

class BookCubit extends Cubit<BookState> {
  final BookRepository repo;

  List<BookModel> _allBooks = [];
  List<BookModel> _filteredBooks = [];

  BookCubit(this.repo) : super(BookInitial());

  // فقط از API می‌خونه
  Future<void> loadBooks({required bool componyMode, String? apiKey}) async {
    emit(BookLoading());
    try {
      final response = !componyMode
          ? await repo.fetchLibrary()
          : await repo.fetchCompaniesBooks(apiKey!);

      if (response != null && response.books.isNotEmpty) {
        _allBooks = response.books;
        _filteredBooks = response.books;
        emit(BookLoaded(_filteredBooks));
      } else {
        emit(BookError('لم يتم استلام أي كتب من واجهة البرمجة.'));
      }
    } catch (e) {
      emit(BookError('حدث خطأ عند استلام الكتب: $e'));
    }
  }

  // جستجو روی کتاب‌های لود شده از API
  void search(String query) {
    if (query.isEmpty) {
      _filteredBooks = _allBooks;
    } else {
      _filteredBooks = _allBooks
          .where(
              (book) => book.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    emit(BookLoaded(_filteredBooks));
  }
}
