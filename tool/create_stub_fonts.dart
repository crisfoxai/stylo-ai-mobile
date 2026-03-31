/// Script to create minimal stub TTF font files for testing.
/// Run with: dart run tool/create_stub_fonts.dart
import 'dart:io';
import 'dart:typed_data';

/// Creates the minimal valid TTF binary header.
/// This is the smallest possible valid-ish TrueType font structure
/// that satisfies Flutter's asset bundle builder (it just needs a non-empty file).
Uint8List minimalTtf() {
  // TrueType/OpenType offset table: sfVersion=0x00010000, numTables=0
  // This is technically invalid but the asset bundler only checks file existence+size
  final buffer = ByteData(12);
  buffer.setUint32(0, 0x00010000); // sfVersion (TrueType)
  buffer.setUint16(4, 0);         // numTables
  buffer.setUint16(6, 0);         // searchRange
  buffer.setUint16(8, 0);         // entrySelector
  buffer.setUint16(10, 0);        // rangeShift
  return buffer.buffer.asUint8List();
}

void main() {
  final fonts = [
    'assets/fonts/PlusJakartaSans/PlusJakartaSans-Regular.ttf',
    'assets/fonts/PlusJakartaSans/PlusJakartaSans-Medium.ttf',
    'assets/fonts/PlusJakartaSans/PlusJakartaSans-SemiBold.ttf',
    'assets/fonts/PlusJakartaSans/PlusJakartaSans-Bold.ttf',
    'assets/fonts/Inter/Inter-Regular.ttf',
    'assets/fonts/Inter/Inter-Medium.ttf',
    'assets/fonts/Inter/Inter-SemiBold.ttf',
  ];

  final stub = minimalTtf();

  for (final path in fonts) {
    final file = File(path);
    if (!file.existsSync() || file.lengthSync() == 0) {
      file.writeAsBytesSync(stub);
      print('Created stub: $path');
    } else {
      print('Skipped (already exists): $path');
    }
  }

  print('Done. ${fonts.length} font stubs ensured.');
}
