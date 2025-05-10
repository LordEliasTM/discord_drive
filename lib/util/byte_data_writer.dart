import 'dart:convert';
import 'dart:typed_data';

class ByteDataWriter {
  late final List<int> data = <int>[];

  final Utf8Encoder _utf8encoder = const Utf8Encoder();

  void writeInt8(int value) => data.addAll(Uint8List(1)..buffer.asInt8List()[0] = value);
  void writeUint8(int value) => data.addAll(Uint8List(1)..buffer.asUint8List()[0] = value);

  void writeInt16(int value) => data.addAll(Uint8List(2)..buffer.asInt16List()[0] = value);
  void writeUint16(int value) => data.addAll(Uint8List(2)..buffer.asUint16List()[0] = value);

  void writeInt32(int value) => data.addAll(Uint8List(4)..buffer.asInt32List()[0] = value);
  void writeUint32(int value) => data.addAll(Uint8List(4)..buffer.asUint32List()[0] = value);

  void writeInt64(int value) => data.addAll(Uint8List(8)..buffer.asInt64List()[0] = value);
  void writeUint64(int value) => data.addAll(Uint8List(8)..buffer.asUint64List()[0] = value);

  void writeFloat32(double value) => data.addAll(Uint8List(4)..buffer.asFloat32List()[0] = value);
  void writeFloat64(double value) => data.addAll(Uint8List(8)..buffer.asFloat64List()[0] = value);

  void writeString(String str, {prependDataLength = true}) {
    var bytes = _utf8encoder.convert(str);
    if (prependDataLength) writeUint8(bytes.length);
    data.addAll(bytes);
  }

  void writeBit8Array(List<bool> bits) {
    int byte = 0;

    for (int i = 0; i < 8; i++) {
      if (bits[i]) {
        byte |= (1 << (7 - i));
      }
    }

    data.add(byte);
  }
}
