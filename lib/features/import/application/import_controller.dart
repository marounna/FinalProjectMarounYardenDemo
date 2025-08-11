import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../data/models/imported_item.dart';
import '../../../shared/providers.dart';

final importControllerProvider = Provider<ImportController>((ref) {
  return ImportController(
    ref: ref,
    picker: ref.watch(filePickerServiceProvider),
    camera: ref.watch(cameraServiceProvider),
  );
});

class ImportController {
  final Ref ref;
  final FilePickerService picker;
  final CameraService camera;
  ImportController({required this.ref, required this.picker, required this.camera});

  Future<void> pickFromFile() async {
    final pages = await picker.pickFile();
    ref.read(pagesProvider.notifier).setAll(
      [for (final p in pages) ImportedItem(name: p.name, bytes: p.bytes)],
    );
  }

  Future<void> captureFromCamera() async {
    final shots = await camera.capturePages();
    ref.read(pagesProvider.notifier).setAll(
      [for (final s in shots) ImportedItem(name: s.name, bytes: s.bytes)],
    );
  }

  void addMock() {
    final demo = Uint8List(0);
    ref.read(pagesProvider.notifier).add(
      ImportedItem(name: 'Page ${DateTime.now().millisecondsSinceEpoch}.png', bytes: demo),
    );
  }
}
