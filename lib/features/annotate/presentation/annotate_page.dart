import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../application/annotate_controller.dart';

class AnnotatePage extends ConsumerWidget {
  const AnnotatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rects = ref.watch(annotateControllerProvider);
    final ctrl = ref.read(annotateControllerProvider.notifier);

    return AppScaffold(
      title: 'Annotate',
      actions: [
        IconButton(onPressed: ctrl.undo, icon: const Icon(Icons.undo)),
        IconButton(onPressed: ctrl.clear, icon: const Icon(Icons.delete_sweep_outlined)),
      ],
      body: LayoutBuilder(
        builder: (context, c) {
          final size = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onPanStart: (d) => ctrl.start(d.localPosition),
            onPanUpdate: (d) => ctrl.update(d.localPosition),
            onPanEnd: (_) => ctrl.end(),
            child: CustomPaint(
              size: size,
              painter: _AnnotPainter(rects: rects, active: ctrl.active),
              child: Container(color: Colors.black12),
            ),
          );
        },
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submit ${rects.length} annotations (wire later)')),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Submit'),
        ),
      ),
    );
  }
}

class _AnnotPainter extends CustomPainter {
  final List<Rect> rects;
  final Rect? active;
  _AnnotPainter({required this.rects, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    for (final r in rects) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), stroke);
    }
    if (active != null) {
      final dashed = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      _drawDashedRect(canvas, active!, dashed);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dash = 8.0; const gap = 6.0;
    double x = rect.left;
    while (x < rect.right) { final nx = (x + dash).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.top), Offset(nx, rect.top), paint); x += dash + gap; }
    x = rect.left;
    while (x < rect.right) { final nx = (x + dash).clamp(rect.left, rect.right);
      canvas.drawLine(Offset(x, rect.bottom), Offset(nx, rect.bottom), paint); x += dash + gap; }
    double y = rect.top;
    while (y < rect.bottom) { final ny = (y + dash).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.left, ny), paint); y += dash + gap; }
    y = rect.top;
    while (y < rect.bottom) { final ny = (y + dash).clamp(rect.top, rect.bottom);
      canvas.drawLine(Offset(rect.right, y), Offset(rect.right, ny), paint); y += dash + gap; }
  }

  @override
  bool shouldRepaint(covariant _AnnotPainter old) => old.rects != rects || old.active != active;
}
