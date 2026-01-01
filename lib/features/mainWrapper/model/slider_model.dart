class HomeModel {
  final List<SliderModel> sliders;
  final List<LastBookModel> lastBooks;
  final List<PageModel> pageModel;

  HomeModel(
      {required this.sliders,
      required this.lastBooks,
      required this.pageModel});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      sliders: (json['sliders'] as List<dynamic>)
          .map((item) => SliderModel.fromJson(item))
          .toList(),
      lastBooks: (json['last_books'] as List<dynamic>)
          .map((item) => LastBookModel.fromJson(item))
          .toList(),
      pageModel: (json['pages'] as List<dynamic>)
          .map((item) => PageModel.fromJson(item))
          .toList(),
    );
  }
}

class SliderModel {
  final int id;
  final String lang;
  final String title;
  final String? link;
  final String startDate;
  final String endDate;
  final String photoUrl;

  SliderModel({
    required this.id,
    required this.lang,
    required this.title,
    this.link,
    required this.startDate,
    required this.endDate,
    required this.photoUrl,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'],
      lang: json['lang'],
      title: json['title'],
      link: json['link'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      photoUrl: json['photo_url'],
    );
  }
}

class LastBookModel {
  final int id;
  final String title;
  final String? writer;
  final String? pdf;
  final String photoUrl;

  LastBookModel({
    required this.id,
    required this.title,
    this.writer,
    this.pdf,
    required this.photoUrl,
  });

  factory LastBookModel.fromJson(Map<String, dynamic> json) {
    return LastBookModel(
      id: json['id'],
      title: json['title'],
      writer: json['writer'],
      pdf: json['pdf'],
      photoUrl: json['photo_url'],
    );
  }
}

class PageModel {
  final int id;
  final String lang;
  final String title;
  final String description;
  final String content;
  final int showCounter;
  final String slug;

  PageModel({
    required this.id,
    required this.lang,
    required this.title,
    required this.description,
    required this.content,
    required this.showCounter,
    required this.slug,
  });

  // تبدیل JSON به PageModel
  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as int,
      lang: json['lang'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      showCounter: json['show_counter'] as int,
      slug: json['slug'] as String,
    );
  }
}
