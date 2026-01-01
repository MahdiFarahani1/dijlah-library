import 'package:bookapp/core/utils/cubit_progress_download_books/cubit/dow_progress_books_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadProgressBar extends StatelessWidget {
  const DownloadProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DowProgressBooksCubit, DownProgressState>(
      builder: (context, state) {
        final percent = (state.progress * 100).round();

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 20,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.amber[800]),
              ),
            ],
          ),
        );
      },
    );
  }
}
