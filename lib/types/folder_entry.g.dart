// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderEntry _$FolderEntryFromJson(Map<String, dynamic> json) => FolderEntry(
      name: json['name'] as String,
      indexMessageId: (json['indexMessageId'] as num).toInt(),
    );

Map<String, dynamic> _$FolderEntryToJson(FolderEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'indexMessageId': instance.indexMessageId,
    };
