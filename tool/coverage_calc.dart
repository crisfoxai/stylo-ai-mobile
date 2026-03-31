import 'dart:io';

void main() {
  final lines = File('coverage/lcov.info').readAsLinesSync();
  int totalLines = 0;
  int coveredLines = 0;
  for (final line in lines) {
    if (line.startsWith('LF:')) {
      totalLines += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      coveredLines += int.parse(line.substring(3));
    }
  }
  final pct = (coveredLines / totalLines * 100);
  print('Total lines: $totalLines');
  print('Covered lines: $coveredLines');
  print('Coverage: ${pct.toStringAsFixed(1)}%');
}
