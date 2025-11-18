import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  // Mock responses for connectivity

  void mockCheckConnectivity(List<ConnectivityResult> results) {
    when(() => checkConnectivity()).thenAnswer((_) async => results);
  }

  void mockCheckConnectivityError(Exception error) {
    when(() => checkConnectivity()).thenThrow(error);
  }

  void mockOnConnectivityChanged() {
    when(() => onConnectivityChanged).thenAnswer((_) => _controller.stream);
  }

  // Helper methods to emit connectivity changes in tests

  void emitConnectivityChange(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  void emitOnline() {
    _controller.add([ConnectivityResult.wifi]);
  }

  void emitOffline() {
    _controller.add([ConnectivityResult.none]);
  }

  void emitMobile() {
    _controller.add([ConnectivityResult.mobile]);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  void closeStream() {
    _controller.close();
  }
}
