import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class FilePickerService {
  Future<List<PickedPage>> pickFile();
}

class PickedPage {
  final String name;
  final Uint8List bytes;
  const PickedPage(this.name, this.bytes);
}

final filePickerServiceProvider = Provider<FilePickerService>((ref) => FilePickerImpl());

class FilePickerImpl implements FilePickerService {
  @override
  Future<List<PickedPage>> pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png','jpg','jpeg','pdf'],
    );
    if (res == null) return [];
    final out = <PickedPage>[];
    for (final f in res.files) {
      final data = f.bytes;
      if (data == null) continue;
      out.add(PickedPage(f.name, data));
    }
    return out;
  }
}
