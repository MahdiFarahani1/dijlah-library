part of 'slider_cubit.dart';

class SliderState {
  StatusSlider statusSlider;
  StatusPages statusPages;
  StatusCompanies statusCompanies;
  int currentIndex;

  SliderState(
      {required this.currentIndex,
      required this.statusSlider,
      required this.statusPages,
      required this.statusCompanies});
  SliderState copyWith(
      {StatusSlider? statusSlider,
      int? currentIndex,
      StatusPages? statusPages,
      StatusCompanies? statusCompanies}) {
    return SliderState(
        statusCompanies: statusCompanies ?? this.statusCompanies,
        currentIndex: currentIndex ?? this.currentIndex,
        statusSlider: statusSlider ?? this.statusSlider,
        statusPages: statusPages ?? this.statusPages);
  }
}

abstract class StatusSlider {}

class SliderLoading extends StatusSlider {}

class SliderLoaded extends StatusSlider {
  final List<SliderModel> sliders;

  SliderLoaded({
    required this.sliders,
  });
}

class SliderError extends StatusSlider {
  final String message;

  SliderError(this.message);
}

abstract class StatusPages {}

class PagesLoading extends StatusPages {}

class PagesLoaded extends StatusPages {
  final List<PageModel> pages;

  PagesLoaded({
    required this.pages,
  });
}

class PagesError extends StatusPages {
  final String message;

  PagesError(this.message);
}

abstract class StatusCompanies {}

class CompaniesLoading extends StatusCompanies {}

class CompaniesLoaded extends StatusCompanies {
  final List<Company> companies;

  CompaniesLoaded({
    required this.companies,
  });
}

class CompaniesError extends StatusCompanies {
  final String message;

  CompaniesError(this.message);
}
