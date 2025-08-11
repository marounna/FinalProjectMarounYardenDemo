import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/imported_item.dart';
import '../data/repositories/session_repository.dart';

final pagesProvider = StateNotifierProvider<PagesController, List<ImportedItem>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return PagesController(repo.pages, onChange: repo.setPages);
});

class PagesController extends StateNotifier<List<ImportedItem>> {
  final void Function(List<ImportedItem>) onChange;
  PagesController(super.state, {required this.onChange});

  void setAll(List<ImportedItem> pages) { state = pages; onChange(state); }
  void add(ImportedItem item) { state = [...state, item]; onChange(state); }
  void clear() { state = []; onChange(state); }
}
