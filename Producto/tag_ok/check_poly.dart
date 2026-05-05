import 'dart:convert';
import 'dart:io';

void main() {
  try {
    final fileStr = File('response.json').readAsStringSync();
    // find index of "polyline":"
    final idx = fileStr.indexOf('"polyline":"');
    if (idx != -1) {
      final endIdx = fileStr.indexOf('"', idx + 12);
      print('Found polyline string of length: ${endIdx - (idx + 12)}');
      print('First 20 chars: ${fileStr.substring(idx + 12, idx + 32)}');
    } else {
      print('NO POLYLINE FOUND');
    }
  } catch(e) {
    print('Error: $e');
  }
}
