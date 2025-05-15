import 'dart:typed_data';

import 'package:discord_drive/types/file_entry.dart';
import 'package:discord_drive/types/folder_index.dart';
import 'package:discord_drive/util/discord_data.dart';
import 'package:discord_drive/util/index_binary_encoder.dart';
import 'package:discord_drive/util/index_binary_parser.dart';
import 'package:nyxx/nyxx.dart';

class IndexManager {
  final NyxxGateway client;
  final Snowflake indexChannelId;
  final Snowflake rootIndexMessageId;

  IndexManager(this.client, this.indexChannelId, this.rootIndexMessageId);

  final DiscordData discordData = DiscordData();

  PartialTextChannel get _indexChannel => client.channels[indexChannelId] as PartialTextChannel;
  PartialMessage get _rootIndexMessage => _indexChannel.messages[rootIndexMessageId];

  Future<void> writeIndex(Snowflake folderIndexMessageId, FolderIndex index) async {
    final data = IndexBinaryEncoder(index: index).encodeIndex();

    final folderIndexMessage = _indexChannel.messages[folderIndexMessageId];
    await discordData.writeDataToDiscord(data, folderIndexMessage);
  }

  Future<FolderIndex> readIndex(Snowflake folderIndexMessageId) async {
    final folderIndexMessage = _indexChannel.messages[folderIndexMessageId];
    final data = await discordData.readDataFromDiscord(folderIndexMessage);

    var index = IndexBinaryParser(data: data).parseIndex();
    return index;
  }

  _convertUint64ListToUint8List(List<int> data) => Uint64List.fromList(data).buffer.asUint8List();
  _convertUint8ListToUint64List(Uint8List data) => Uint64List.view(data.buffer).toList();

  Future<Message> _createChunkIndexOnDiscord(List<int> chunkIds) async {
    final data = _convertUint64ListToUint8List(chunkIds);
    return await discordData.createDataOnDiscord(data, _indexChannel);
  }

  Future<List<int>> readChunkIndex(Snowflake chunkIndexMessageId) async {
    final chunkIndexMessage = _indexChannel.messages[chunkIndexMessageId];
    final data = await discordData.readDataFromDiscord(chunkIndexMessage);
    return _convertUint8ListToUint64List(data);
  }

  Future<FolderIndex> addFileToIndex(Snowflake folderIndexMessageId, List<int> chunkIds, String name, int size) async {
    final chunkIndexMessage = await _createChunkIndexOnDiscord(chunkIds);
    final file = FileEntry(name: name, chunkIndexMessageId: chunkIndexMessage.id.value, size: size);

    final index = await readIndex(folderIndexMessageId);
    index.files.add(file);
    await writeIndex(folderIndexMessageId, index);
    return index;
  }
}
