import 'package:json_annotation/json_annotation.dart';

part 'folder_entry.g.dart';

@JsonSerializable()
class FolderEntry {
  const FolderEntry({
    required this.name,
    required this.indexMessageId,
  });

  final String name;
  final int indexMessageId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get id => indexMessageId;

  factory FolderEntry.fromJson(Map<String, dynamic> json) => _$FolderEntryFromJson(json);
  Map<String, dynamic> toJson() => _$FolderEntryToJson(this);
}
