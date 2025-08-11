import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

abstract class CameraService {
  /// Opens camera once and returns one captured image as a page (PNG/JPEG bytes).
  Future<List<CameraCapture>> capturePages();

  /// (Optional) pick multiple images from gallery
  Future<List<CameraCapture>> pickFromGallery();
}

class CameraCapture {
  final String name;
  final Uint8List bytes;
  const CameraCapture(this.name, this.bytes);
}

final cameraServiceProvider = Provider<CameraService>((ref) => CameraServiceImpl());

class CameraServiceImpl implements CameraService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<CameraCapture>> capturePages() async {
    final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    if (shot == null) return [];
    final bytes = await shot.readAsBytes();
    return [CameraCapture(shot.name, bytes)];
  }

  @override
  Future<List<CameraCapture>> pickFromGallery() async {
    final list = await _picker.pickMultiImage(imageQuality: 95);
    if (list.isEmpty) return [];
    final out = <CameraCapture>[];
    for (final x in list) {
      out.add(CameraCapture(x.name, await x.readAsBytes()));
    }
    return out;
  }
}
