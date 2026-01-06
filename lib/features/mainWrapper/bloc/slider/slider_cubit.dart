import 'package:bookapp/features/mainWrapper/model/slider_model.dart';
import 'package:bookapp/features/mainWrapper/repository/slider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'slider_state.dart';

class SliderCubit extends Cubit<SliderState> {
  SliderCubit()
      : super(SliderState(
          statusSlider: SliderLoading(),
          statusPages: PagesLoading(),
          statusCompanies: CompaniesLoading(),
          currentIndex: 0,
        ));

  Future<void> loadHomeData() async {
    // 1. همه وضعیت‌ها رو Loading کن
    emit(state.copyWith(
      statusSlider: SliderLoading(),
      statusPages: PagesLoading(),
      statusCompanies: CompaniesLoading(),
    ));

    try {
      // 2. JSON خام از Repository
      final data = await SliderRepository.fetchHomeJson();

      // 3. ساخت مدل‌ها اینجا
      final sliders = (data['sliders'] as List)
          .map((json) => SliderModel.fromJson(json))
          .toList();

      final pages = (data['pages'] as List)
          .map((json) => PageModel.fromJson(json))
          .toList();

      final companies = (data['companies'] as List)
          .map((json) => Company.fromJson(json))
          .toList();

      // 4. Emit وضعیت Loaded با مدل‌ها
      emit(state.copyWith(
        statusSlider: SliderLoaded(sliders: sliders),
        statusPages: PagesLoaded(pages: pages),
        statusCompanies: CompaniesLoaded(companies: companies),
      ));
      print('api loadedddddddd');
    } catch (e) {
      // همه وضعیت‌ها رو Error کن
      emit(state.copyWith(
        statusSlider: SliderError(e.toString()),
        statusPages: PagesError(e.toString()),
        statusCompanies: CompaniesError(e.toString()),
      ));
      print(e.toString());
    }
  }

  void indicatorChanged(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
