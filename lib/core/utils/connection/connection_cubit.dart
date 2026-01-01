import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectionStatus { initial, online, offline }

class ConnectionStat {
  // ConnectionState is taken by Flutter
  final ConnectionStatus status;
  const ConnectionStat(this.status);
}

class ConnectionCubit extends Cubit<ConnectionStat> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectionCubit() : super(const ConnectionStat(ConnectionStatus.initial)) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        emit(const ConnectionStat(ConnectionStatus.offline));
      } else {
        emit(const ConnectionStat(ConnectionStatus.online));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
