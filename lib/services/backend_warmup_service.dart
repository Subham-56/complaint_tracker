/// Tracks whether the single app-launch backend wake-up ping (fired once in
/// main.dart) has completed. Screens that want to show a "waking up server"
/// indicator should listen to [isWarm] / [onWarm] instead of firing their own
/// separate ping — avoids redundant requests to the cold-start backend.
class BackendWarmupService {
  BackendWarmupService._();

  static bool _isWarm = false;
  static final List<void Function()> _listeners = [];

  static bool get isWarm => _isWarm;

  static void markWarmupComplete() {
    if (_isWarm) return;
    _isWarm = true;
    for (final listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  /// Registers [listener] to be called once, the first time warmup
  /// completes. If warmup has already completed, calls it immediately.
  static void onWarm(void Function() listener) {
    if (_isWarm) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }
}