import 'dart:typed_data';

class ImportedItem {
  final String name;
  final Uint8List? bytes;
  const ImportedItem({required this.name, this.bytes});
}
