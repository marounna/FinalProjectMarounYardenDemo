import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/imported_item.dart';

abstract class SessionRepository {
  List<ImportedItem> get pages;
  void setPages(List<ImportedItem> pages);
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) => _MemorySessionRepo());

class _MemorySessionRepo implements SessionRepository {
  List<ImportedItem> _pages = const [];
  @override
  List<ImportedItem> get pages => _pages;

  @override
  void setPages(List<ImportedItem> pages) => _pages = pages;
}
