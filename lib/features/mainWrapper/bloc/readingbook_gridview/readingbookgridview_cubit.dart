import 'package:bloc/bloc.dart';

part 'readingbookgridview_state.dart';

class ReadingbookgridviewCubit extends Cubit<ReadingbookgridviewState> {
  ReadingbookgridviewCubit() : super(ReadingbookgridviewState(gridCount: 2));

  changeGridView(int number) {
    emit(ReadingbookgridviewState(gridCount: number));
  }
}
