import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:discord_drive/index_manager.dart';
import 'package:discord_drive/types/file_entry.dart';
import 'package:discord_drive/types/folder_index.dart';
import 'package:discord_drive/util/discord_data.dart';
import 'package:discord_drive/util/index_binary_encoder.dart';
import 'package:nyxx/nyxx.dart';

const maxChunkSize = 10 * 1024 * 1024; // 10 MB is max for Bots

class DiscordDrive {
  late final NyxxGateway client;
  late final Snowflake driveChannelId;
  late final Snowflake indexChannelId;
  late final Snowflake rootFolderId;
  late final IndexManager indexManager;

  DiscordDrive(String driveChannelId, String indexChannelId, String rootFolderId) {
    this.driveChannelId = Snowflake.parse(driveChannelId);
    this.indexChannelId = Snowflake.parse(indexChannelId);
    this.rootFolderId = Snowflake.parse(rootFolderId);
  }

  PartialTextChannel get _driveChannel => client.channels[driveChannelId] as PartialTextChannel;

  Future<DiscordDrive> connect(String token) async {
    client = await Nyxx.connectGateway(token, GatewayIntents.allUnprivileged, options: GatewayClientOptions(plugins: [logging]));
    indexManager = IndexManager(client, indexChannelId, rootFolderId);
    return this;
  }

  Future<FolderIndex> readRootFolderIndex() async {
    return await indexManager.readIndex(rootFolderId);
  }

  Future<FolderIndex> uploadFile(String folderId, String fileName, Stream<List<int>> data) async {
    final reader = ChunkedStreamReader(data);
    final chunkIds = <int>[];
    int totalBytesRead = 0;

    for(var chunkId = 0; true; chunkId++) {
      print("Processing chunk $chunkId");
      final chunk = await reader.readBytes(maxChunkSize);
      if(chunk.isEmpty) break;

      final attachments = [AttachmentBuilder(data: chunk, fileName: "$fileName\_$chunkId")];
      final msg = await _driveChannel.sendMessage(MessageBuilder(attachments: attachments));

      chunkIds.add(msg.id.value);
      totalBytesRead += chunk.length;

      if(chunk.length < maxChunkSize) break; // End of file
    }

    return await indexManager.addFileToIndex(Snowflake.parse(folderId), chunkIds, fileName, totalBytesRead);
  }

  static Future<String> createRootFolderMessage(String indexChannelId, String token) async {
    final client = await Nyxx.connectRest(token);
    final discordData = DiscordData();
    
    final index = FolderIndex(
      version: 1,
      lastEdit: DateTime.now().millisecondsSinceEpoch,
      files: [],
      folders: [],
    );
    final data = IndexBinaryEncoder(index: index).encodeIndex();

    final indexChannel = client.channels[Snowflake.parse(indexChannelId)] as PartialTextChannel;
    final message = await discordData.createDataOnDiscord(data, indexChannel);

    client.close();
    return message.id.toString();
  }
}
