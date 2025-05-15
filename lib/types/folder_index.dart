import 'package:discord_drive/types/file_entry.dart';
import 'package:discord_drive/types/folder_entry.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_index.g.dart';

@JsonSerializable()
class FolderIndex {
  const FolderIndex({
    required this.version,
    required this.lastEdit,
    required this.files,
    required this.folders,
  });

  final int version;
  final int lastEdit;
  final List<FileEntry> files;
  final List<FolderEntry> folders;

  factory FolderIndex.fromJson(Map<String, dynamic> json) => _$FolderIndexFromJson(json);
  Map<String, dynamic> toJson() => _$FolderIndexToJson(this);
}
