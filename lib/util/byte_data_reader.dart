import 'dart:convert';
import 'dart:typed_data';

class ByteDataReader {
  ByteDataReader({required Uint8List data}) {
    this.data = ByteData.sublistView(data);
  }

  late final ByteData data;
  final Utf8Decoder _utf8decoder = const Utf8Decoder();
  int _counter = 0;

  bool get finished => _counter >= data.lengthInBytes;

  int readInt8() {
    final int value = data.getInt8(_counter);
    _counter += 1;

    return value;
  }

  int readUint8() {
    final int value = data.getUint8(_counter);
    _counter += 1;

    return value;
  }

  int readInt16([Endian endian = Endian.little]) {
    final int value = data.getInt16(_counter, endian);
    _counter += 2;

    return value;
  }

  int readUint16([Endian endian = Endian.little]) {
    final int value = data.getUint16(_counter, endian);
    _counter += 2;

    return value;
  }

  int readInt32([Endian endian = Endian.little]) {
    final int value = data.getInt32(_counter, endian);
    _counter += 4;

    return value;
  }

  int readUint32([Endian endian = Endian.little]) {
    final int value = data.getUint32(_counter, endian);
    _counter += 4;

    return value;
  }

  int readInt64([Endian endian = Endian.little]) {
    final int value = data.getInt64(_counter, endian);
    _counter += 8;

    return value;
  }

  int readUint64([Endian endian = Endian.little]) {
    final int value = data.getUint64(_counter, endian);
    _counter += 8;

    return value;
  }

  double readFloat32([Endian endian = Endian.little]) {
    final double value = data.getFloat32(_counter, endian);
    _counter += 4;

    return value;
  }

  double readFloat64([Endian endian = Endian.little]) {
    final double value = data.getFloat64(_counter, endian);
    _counter += 8;

    return value;
  }

  String readString(int length) {
    final Uint8List view = Uint8List.sublistView(data, _counter, _counter + length);
    final String value = _utf8decoder.convert(view);
    _counter += length;

    return value;
  }

  List<bool> readBit8Array() {
    final int value = readUint8();
    final List<bool> flags = <bool>[];

    for (int i = 0; i < 8; i++) {
      flags.add(
        (value & (1 << (7 - i))) != 0,
      );
    }

    return flags;
  }
}
