import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the global simulation time across all steps
final sceneTimeProvider = StateProvider<int>((ref) => 0);

/// Logic to auto-increment the timer
final sceneTimerControllerProvider = Provider((ref) {
  Timer? timer;
  
  void start() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      ref.read(sceneTimeProvider.notifier).state++;
    });
  }

  void stop() {
    timer?.cancel();
  }

  void reset() {
    ref.read(sceneTimeProvider.notifier).state = 0;
  }

  return {
    'start': start,
    'stop': stop,
    'reset': reset,
  };
});
