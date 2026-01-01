import 'package:bookapp/features/mainWrapper/repository/first_enter_bool.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit()
      : super(EnterStorageService().readFirstEnter() == true ? 0 : 1);
  void setPage(int index) => emit(index);
}
