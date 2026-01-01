import 'package:bloc/bloc.dart';

class HeaderAnimationCubit extends Cubit<bool> {
  HeaderAnimationCubit() : super(true);

  hideHeader() {
    final bool anim = false;

    emit(anim);
  }

  showHeader() {
    final bool anim = true;

    emit(anim);
  }
}
