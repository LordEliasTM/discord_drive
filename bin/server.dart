import 'package:discord_drive/discord_drive.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init, defaultBindPort: 1000);

Future<Handler> init() async {
  var env = DotEnv()..load();
  final app = Router().plus;

  final DiscordDrive discordDrive = DiscordDrive(env["DRIVE_CHANNEL_ID"]!, env["INDEX_CHANNEL_ID"]!, env["ROOT_INDEX_MESSAGE_ID"]!);
  await discordDrive.connect(env["BOT_TOKEN"]!);

  app.use(logRequests());

  app.post('/createRootFolder', () async => 
    await DiscordDrive.createRootFolderMessage(env["INDEX_CHANNEL_ID"]!, env["BOT_TOKEN"]!));

  app.get("/readRootFolderIndex", () async => 
    await discordDrive.readRootFolderIndex());

  app.post("/<folderId>/uploadFile", (Request request, String folderId) async {
    if(request.url.queryParameters['fileName'] case var fileName?) {
      print("$folderId $fileName");
      return discordDrive.uploadFile(folderId, fileName, request.read());
    }
    else {
      return Response(400, body: 'Query parameter fileName is required');
    }
  });

  return app.call;
}
