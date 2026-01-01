import 'package:bloc/bloc.dart';
import 'package:bookapp/config/storage/download_progress_storage.dart';
import 'package:equatable/equatable.dart';

part 'dow_progress_books_state.dart';

class DowProgressBooksCubit extends Cubit<DownProgressState> {
  DowProgressBooksCubit()
      : super(DownProgressState(
          progress: 0,
        ));

  void initialize() {
    final progress = DownloadProgressStorage.getProgress();
    emit(DownProgressState(progress: progress));
  }

  void updateProgress() {
    final progress = DownloadProgressStorage.getProgress();

    emit(DownProgressState(progress: progress));
  }
}
