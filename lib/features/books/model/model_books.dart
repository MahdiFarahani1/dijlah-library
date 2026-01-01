import 'dart:convert';

class LibraryResponse {
  final List<BookModel> books;
  final CompanyModel company;
  final List<CategoryModel> categories;
  final String lastUpdate;
  LibraryResponse({
    required this.books,
    required this.company,
    required this.categories,
    required this.lastUpdate,
  });

  factory LibraryResponse.fromJson(Map<String, dynamic> json) {
    return LibraryResponse(
      books: (json['books'] as List).map((e) => BookModel.fromJson(e)).toList(),
      company: CompanyModel.fromJson(json['company']),
      categories: (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      lastUpdate: json['last_update'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'books': books.map((e) => e.toJson()).toList(),
        'company': company.toJson(),
        'categories': categories.map((e) => e.toJson()).toList(),
      };

  static LibraryResponse fromJsonString(String str) =>
      LibraryResponse.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

class BookModel {
  final int id;
  final int part;
  final int categoryId;
  final String title;
  final int dateTime;
  final String updatedAt;
  final int idShow;
  final String bookCode;
  final String? description;
  final int internationalNumber;
  final String? publisher;
  final int changedPages;
  final String? deletedAt;
  final String photoUrl;
  final String pdfLink;
  final String epubLink;
  final String soundUrl;
  final String writerName;
  final String scholarName;
  final int numberPages;
  final CategoryModel category;

  BookModel({
    required this.id,
    required this.part,
    required this.categoryId,
    required this.title,
    required this.dateTime,
    required this.updatedAt,
    required this.idShow,
    required this.bookCode,
    this.description,
    required this.internationalNumber,
    this.publisher,
    required this.changedPages,
    this.deletedAt,
    required this.photoUrl,
    required this.pdfLink,
    required this.epubLink,
    required this.soundUrl,
    required this.writerName,
    required this.scholarName,
    required this.numberPages,
    required this.category,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      part: json['part'],
      categoryId: json['category_id'],
      title: json['title'] ?? '',
      dateTime: json['date_time'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      idShow: json['id_show'] ?? 0,
      bookCode: json['book_code'] ?? '',
      description: json['description'],
      internationalNumber: json['international_number'] ?? 0,
      publisher: json['publisher'],
      changedPages: json['changed_pages'] ?? 0,
      deletedAt: json['deleted_at'],
      photoUrl: json['photo_url'] ?? '',
      pdfLink: json['pdf_link'] ?? '',
      epubLink: json['epub_link'] ?? '',
      soundUrl: json['sound_url'] ?? '',
      writerName: json['writer_name'] ?? '',
      scholarName: json['scholar_name'] ?? '',
      numberPages: json['number_pages'] ?? 0,
      category: CategoryModel.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'part': part,
        'category_id': categoryId,
        'title': title,
        'date_time': dateTime,
        'updated_at': updatedAt,
        'id_show': idShow,
        'book_code': bookCode,
        'description': description,
        'international_number': internationalNumber,
        'publisher': publisher,
        'changed_pages': changedPages,
        'deleted_at': deletedAt,
        'photo_url': photoUrl,
        'pdf_link': pdfLink,
        'epub_link': epubLink,
        'sound_url': soundUrl,
        'writer_name': writerName,
        'scholar_name': scholarName,
        'number_pages': numberPages,
        'category': category.toJson(),
      };
}

class CategoryModel {
  final int id;
  final String title;
  final String slug;
  final int booksCount;

  CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.booksCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      booksCount: json['books_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'books_count': booksCount,
      };
}

class CompanyModel {
  final int id;
  final String title;
  final String companyDomain;
  final String img;
  final String? description;
  final String apiToken;
  final String payload;
  final String primaryColor;
  final String secondaryColor;
  final bool active;
  final String createdAt;
  final String updatedAt;
  final String photoUrl;

  CompanyModel({
    required this.id,
    required this.title,
    required this.companyDomain,
    required this.img,
    this.description,
    required this.apiToken,
    required this.payload,
    required this.primaryColor,
    required this.secondaryColor,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.photoUrl,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      title: json['title'] ?? '',
      companyDomain: json['company_domain'] ?? '',
      img: json['img'] ?? '',
      description: json['description'],
      apiToken: json['api_token'] ?? '',
      payload: json['payload'] ?? '',
      primaryColor: json['primary_color'] ?? '',
      secondaryColor: json['secondary_color'] ?? '',
      active: json['active'] == 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company_domain': companyDomain,
        'img': img,
        'description': description,
        'api_token': apiToken,
        'payload': payload,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'active': active ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'photo_url': photoUrl,
      };
}
