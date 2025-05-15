import 'package:discord_drive/discord_drive.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> arguments) async {
  var env = DotEnv()..load();

  final id = await DiscordDrive.createRootFolderMessage(env["INDEX_CHANNEL_ID"]!, env["BOT_TOKEN"]!);
  print("Root folder message ID: $id");
}
