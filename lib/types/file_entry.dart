import 'package:json_annotation/json_annotation.dart';

part 'file_entry.g.dart';

@JsonSerializable()
class FileEntry {
  const FileEntry({
    required this.name,
    required this.chunkIndexMessageId,
    required this.size,
    // TODO add upload timestamp
  });

  final String name;
  final int chunkIndexMessageId;
  final int size;

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get id => chunkIndexMessageId;

  factory FileEntry.fromJson(Map<String, dynamic> json) => _$FileEntryFromJson(json);
  Map<String, dynamic> toJson() => _$FileEntryToJson(this);
}
