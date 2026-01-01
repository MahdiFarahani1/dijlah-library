part of 'dow_progress_books_cubit.dart';

class DownProgressState extends Equatable {
  final double progress;

  const DownProgressState({
    required this.progress,
  });

  @override
  List<Object?> get props => [progress];
}
