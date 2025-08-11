import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/widgets/app_scaffold.dart";
import "../application/analysis_controller.dart";

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(analysisControllerProvider);
    final ctrl = ref.read(analysisControllerProvider.notifier);

    return AppScaffold(
      title: "Analysis",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StageTile(title: "OCR",      active: s.stage == AnalysisStage.ocr,    done: s.stage.index > AnalysisStage.ocr.index),
            _StageTile(title: "Detect",   active: s.stage == AnalysisStage.detect, done: s.stage.index > AnalysisStage.detect.index),
            _StageTile(title: "Generate", active: s.stage == AnalysisStage.gen3d,  done: s.stage.index > AnalysisStage.gen3d.index),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: s.stage == AnalysisStage.done ? 1 : (s.progress <= 0 ? null : s.progress)),
            const SizedBox(height: 8),
            Text(s.message ?? "", style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Row(
              children: [
                OutlinedButton.icon(onPressed: ctrl.reset, icon: const Icon(Icons.refresh), label: const Text("Reset")),
                const SizedBox(width: 8),
                FilledButton.icon(onPressed: ctrl.start, icon: const Icon(Icons.play_arrow), label: const Text("Start")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final String title;
  final bool active;
  final bool done;
  const _StageTile({required this.title, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    final icon = done ? Icons.check_circle : (active ? Icons.timelapse : Icons.radio_button_unchecked);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      dense: true,
    );
  }
}
