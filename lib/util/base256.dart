import 'dart:typed_data';

String encodeBase256(List<int> data) {
  return data.map((int e) => String.fromCharCode(e + 192)).join();
}

Uint8List decodeBase256(String str) {
  return Uint8List.fromList(str.codeUnits.map((e) => e - 192).toList());
}
