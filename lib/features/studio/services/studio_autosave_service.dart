import 'dart:async';

class StudioAutoSaveService {
  Timer? _timer;

  //--------------------------------------------------
  // SCHEDULE AUTO SAVE
  //--------------------------------------------------

  void scheduleAutoSave({
    required Future<void> Function() save,
    Duration delay = const Duration(seconds: 2),
  }) {
    _timer?.cancel();

    _timer = Timer(delay, () async {
      await save();
    });
  }

  //--------------------------------------------------
  // CANCEL
  //--------------------------------------------------

  void cancel() {
    _timer?.cancel();
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  void dispose() {
    _timer?.cancel();
  }
}