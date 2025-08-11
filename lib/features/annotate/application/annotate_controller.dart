import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final annotateControllerProvider = StateNotifierProvider<AnnotateController, List<Rect>>((ref) {
  return AnnotateController();
});

class AnnotateController extends StateNotifier<List<Rect>> {
  AnnotateController() : super(const []);
  Rect? active;

  void start(Offset p) { active = Rect.fromLTWH(p.dx, p.dy, 0, 0); }
  void update(Offset p) {
    if (active == null) return;
    final start = Offset(active!.left, active!.top);
    active = Rect.fromPoints(start, p);
    state = [...state];
  }
  void end() {
    if (active == null) return;
    final r = _normalize(active!);
    state = [...state, r];
    active = null;
  }
  void undo() { if (state.isNotEmpty) { state = [...state]..removeLast(); } }
  void clear() { state = const []; active = null; }

  Rect _normalize(Rect r) {
    final left = r.left < r.right ? r.left : r.right;
    final top = r.top < r.bottom ? r.top : r.bottom;
    final right = r.left < r.right ? r.right : r.left;
    final bottom = r.top < r.bottom ? r.bottom : r.top;
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
