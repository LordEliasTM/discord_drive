import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:discord_drive/index_manager.dart';
import 'package:discord_drive/types/file_entry.dart';
import 'package:discord_drive/types/folder_entry.dart';
import 'package:discord_drive/types/folder_index.dart';
import 'package:discord_drive/util/discord_data.dart';
import 'package:discord_drive/util/index_binary_encoder.dart';
import 'package:discord_drive/util/message_list_extension.dart';
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

  Future<List<Message>> _fetchChunkMessages(List<int> chunkIds) async {
    final List<Message> messages = [];

    Snowflake afterId = Snowflake.parse(chunkIds.first - 1); // -1 to also include the first message in the fetch
    int limit = chunkIds.length.clamp(1, 100);
    // TODO find better way with the limits (i.e. 50 chunks -> x2 = 100, which is way too much for the followup fetch)
    // TODO also if i.e. 202 chunks, it fetches 100, then another 100, and another 100 even though only 2 are remaining

    do {
      messages.addAll(await _driveChannel.messages.fetchMany(after: afterId, limit: limit));
      messages.sortByIdAscending(); // Sort by ID to ensure chronological order
      afterId = messages.last.id;
      limit = (limit * 2).clamp(1, 100);
    } while (!messages.containsAllIds(chunkIds));

    return messages.filterByIds(chunkIds);
  }

  Future<List<String>> getFileChunkLinks(String chunkIndexMessageId) async {
    // TODO implement method to just get the chunk message IDs, because links expire in 24h
    // TODO -> chunk links shall then be rquested sequentially or in batches
    final chunkIds = await indexManager.readChunkIndex(Snowflake.parse(chunkIndexMessageId));
    final messages = await _fetchChunkMessages(chunkIds);
    final chunkLinks = messages.map((message) => message.attachments.first.url.toString()).toList();
    return chunkLinks;
  }

  Future<FolderIndex> createFolder(String parentFolderId, String folderName) async {
    final index = await indexManager.createFolderIndex();
    final entry = FolderEntry(name: folderName, indexMessageId: index.id.value);
    return await indexManager.addFolderToIndex(Snowflake.parse(parentFolderId), entry);
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
