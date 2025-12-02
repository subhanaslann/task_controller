import 'dart:async';

/// TekTech Debounce Utility
/// 
/// Delays function execution until after a specified duration
/// - Useful for search input optimization
/// - Cancels previous pending calls
/// - Reduces API calls
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  bool get isActive => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
  }
}

/// Extension method for debouncing on any function
extension DebouncedFunction on void Function() {
  void Function() debounced(Duration duration) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, this);
    };
  }
}
