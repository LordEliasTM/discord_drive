import 'dart:io';
import 'dart:typed_data';

import 'package:discord_drive/util/base256.dart';
import 'package:nyxx/nyxx.dart';

class DiscordData {
  /// Writes data to discord by editing an existing message
  Future<void> writeDataToDiscord(Uint8List data, PartialMessage message, {bool compress = true}) async {
    if (compress) data = Uint8List.fromList(gzip.encode(data));
    final overMessageSizeLimit = data.length > 2000;

    // TODO If previous version of the data was saved as file, delete the old file (perhaps async subroutine to not block)
    // TODO Or write something that gets all messages in the index channel and checks cross references, basically garbage collector

    // if not over limit just put it in the message
    // if over limit upload as file and reference it fromt he message
    if (!overMessageSizeLimit) {
      await message.edit(MessageUpdateBuilder(content: encodeBase256(data)));
    } else {
      // TODO perhaps remove msg id from name
      final attachements = [AttachmentBuilder(data: data, fileName: "discordData_${message.id}")];
      final fileMessage = await message.channel.sendMessage(MessageBuilder(attachments: attachements));
      await message.edit(MessageUpdateBuilder(content: "#${fileMessage.id}"));
    }
  }

  /// Crteates data on discord by sending a new message in the provided channel
  Future<Message> createDataOnDiscord(Uint8List data, PartialTextChannel channel, {bool compress = true}) async {
    if (compress) data = Uint8List.fromList(gzip.encode(data));
    final overMessageSizeLimit = data.length > 2000;

    // if not over limit just put it in the message
    // if over limit upload as file and reference it fromt he message
    if (!overMessageSizeLimit) {
      return await channel.sendMessage(MessageBuilder(content: encodeBase256(data)));
    } else {
      final attachements = [AttachmentBuilder(data: data, fileName: "discordData_0")];
      final fileMessage = await channel.sendMessage(MessageBuilder(attachments: attachements));
      return await channel.sendMessage(MessageBuilder(content: "#${fileMessage.id}"));
    }
  }

  bool _isCompressed(Uint8List data) => data[0] == 0x1f && data[1] == 0x8b;

  /// Reads data from a discord message
  Future<Uint8List> readDataFromDiscord(PartialMessage message) async {
    final msg = (await message.get()).content;
    final overMessageSizeLimit = msg[0] == "#";

    Uint8List data;

    if (!overMessageSizeLimit) {
      data = decodeBase256(msg);
    } else {
      // format is #1201581445228015749, so need to remove hashtag
      final fileMessageId = Snowflake.parse(msg.substring(1));
      final fileMessage = await message.channel.messages.get(fileMessageId);
      data = await fileMessage.attachments[0].fetch();
    }

    if (_isCompressed(data)) {
      data = Uint8List.fromList(gzip.decode(data));
    }

    return data;
  }
}
