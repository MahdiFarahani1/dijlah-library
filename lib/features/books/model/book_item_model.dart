class BookItem {
  final String id;
  final List<int> imageData;
  final String title;
  final String author;
  final String date;
  final int pageNumbers;
  final String category;
  BookItem(
      {required this.id,
      required this.imageData,
      required this.title,
      required this.author,
      required this.date,
      required this.pageNumbers,
      required this.category});
}
