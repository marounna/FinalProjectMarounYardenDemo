import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum AnalysisStage { idle, ocr, detect, gen3d, done, error }

final analysisControllerProvider = StateNotifierProvider<AnalysisController, AnalysisState>((ref) {
  return AnalysisController();
});

class AnalysisState {
  final AnalysisStage stage;
  final double progress; // 0..1
  final String? message;
  const AnalysisState({required this.stage, required this.progress, this.message});
  AnalysisState copyWith({AnalysisStage? stage, double? progress, String? message}) =>
      AnalysisState(stage: stage ?? this.stage, progress: progress ?? this.progress, message: message ?? this.message);
  static const initial = AnalysisState(stage: AnalysisStage.idle, progress: 0);
}

class AnalysisController extends StateNotifier<AnalysisState> {
  AnalysisController(): super(AnalysisState.initial);

  Timer? _timer;

  Future<void> start() async {
    _timer?.cancel();
    state = const AnalysisState(stage: AnalysisStage.ocr, progress: 0.0, message: "Running OCR...");
    _fakeRun([
      (AnalysisStage.ocr,   "OCRâ€¦"),
      (AnalysisStage.detect,"Detecting partsâ€¦"),
      (AnalysisStage.gen3d, "Generating 3Dâ€¦"),
    ]);
  }

  void _fakeRun(List<(AnalysisStage,String)> steps) {
    int i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (i < steps.length) {
        final (st, msg) = steps[i];
        state = AnalysisState(stage: st, progress: (i / steps.length).toDouble(), message: msg);
        i++;
      } else {
        t.cancel();
        state = const AnalysisState(stage: AnalysisStage.done, progress: 1.0, message: "Complete");
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = AnalysisState.initial;
  }
}
