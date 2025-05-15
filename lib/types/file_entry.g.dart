// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileEntry _$FileEntryFromJson(Map<String, dynamic> json) => FileEntry(
      name: json['name'] as String,
      chunkIndexMessageId: (json['chunkIndexMessageId'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$FileEntryToJson(FileEntry instance) => <String, dynamic>{
      'name': instance.name,
      'chunkIndexMessageId': instance.chunkIndexMessageId,
      'size': instance.size,
    };
