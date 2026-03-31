import 'dart:io';

void main() {
  final lines = File('coverage/lcov.info').readAsLinesSync();
  var lf = 0;
  var lh = 0;
  for (final line in lines) {
    if (line.startsWith('LF:')) lf += int.parse(line.substring(3));
    if (line.startsWith('LH:')) lh += int.parse(line.substring(3));
  }
  final pct = lf > 0 ? (lh / lf * 100) : 0.0;
  print('Total lines: $lf');
  print('Covered lines: $lh');
  print('Coverage: ${pct.toStringAsFixed(1)}%');
}
