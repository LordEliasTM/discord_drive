import 'dart:typed_data';

import 'package:discord_drive/types/folder_index.dart';
import 'package:discord_drive/util/byte_data_writer.dart';

class IndexBinaryEncoder extends ByteDataWriter {
  IndexBinaryEncoder({required this.index});

  final FolderIndex index;

  Uint8List encodeIndex() {
    writeUint8(index.version);
    writeUint64(index.lastEdit);

    for (var file in index.files) {
      // isDirectory, reserved...
      writeBit8Array([false, false, false, false, false, false, false, false]);
      writeUint64(file.chunkIndexMessageId);
      writeUint64(file.size);
      writeString(file.name, prependDataLength: true);
    }

    for (var folder in index.folders) {
      // isDirectory, reserved...
      writeBit8Array([true, false, false, false, false, false, false, false]);
      writeUint64(folder.indexMessageId);
      writeString(folder.name, prependDataLength: true);
    }

    return Uint8List.fromList(data);
  }
}
