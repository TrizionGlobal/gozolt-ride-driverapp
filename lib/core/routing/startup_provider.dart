import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupNotifier extends ValueNotifier<bool> {
  StartupNotifier() : super(false);

  void markInitialized() {
    value = true;
  }
}

final startupProvider = Provider<StartupNotifier>((ref) {
  return StartupNotifier();
});
